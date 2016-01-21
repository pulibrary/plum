# rubocop:disable Metrics/ClassLength
class CurationConcerns::CurationConcernsController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::Collectible

  def curation_concern_name
    curation_concern.class.name.underscore
  end

  def curation_concern
    if wants_to_update_remote_metadata?
      decorated_concern
    else
      @curation_concern
    end
  end

  def manifest
    respond_to do |f|
      f.json do
        render json: manifest_builder
      end
    end
  end

  def deny_access(exception)
    if exception.action == :manifest && !current_user
      render json: AuthManifestBuilder.auth_services(login_url, nil), status: 401
    elsif !current_user
      session['user_return_to'.freeze] = request.url
      redirect_to login_url, alert: exception.message
    else
      super
    end
  end

  def update
    authorize!(:complete, @curation_concern, message: 'Unable to mark resource complete') if @curation_concern.state != 'complete' && params[curation_concern_name][:state] == 'complete'
    add_to_collections(params[curation_concern_name].delete(:collection_ids))
    super
  end

  def bulk_edit
    @members = presenter.file_presenters
  end

  def save_order
    lock_manager.lock(curation_concern.id) do
      form = ReorderForm.new(curation_concern)
      form.order = params[:order]
      if form.save
        render json: { message: "Successfully updated order." }
      else
        render json: { message: form.errors.full_messages.to_sentence }, status: :bad_request
      end
    end
  end

  def flag
    curation_concern.state = 'flagged'
    note = params[curation_concern_name][:workflow_note]
    curation_concern.workflow_note = curation_concern.workflow_note + [note] unless note.blank?
    if curation_concern.save
      respond_to do |format|
        format.html { redirect_to [main_app, curation_concern], notice: "Resource updated" }
        format.json { render json: { state: state } }
      end
    else
      respond_to do |format|
        format.html { redirect_to [main_app, curation_concern], alert: "Unable to update resource" }
        format.json { render json: { error: "Unable to update resource" } }
      end
    end
  end

  def browse_everything_files
    upload_set_id = ActiveFedora::Noid::Service.new.mint
    CompositePendingUpload.create(selected_files_params, curation_concern.id, upload_set_id)
    BrowseEverythingIngestJob.perform_later(curation_concern.id, upload_set_id, current_user, selected_files_params)
    redirect_to main_app.bulk_edit_curation_concerns_scanned_resource_path(curation_concern)
  end

  private

    def lock_manager
      @lock_manager ||= CurationConcerns::LockManager.new(
        CurationConcerns.config.lock_time_to_live,
        CurationConcerns.config.lock_retry_count,
        CurationConcerns.config.lock_retry_delay)
    end

    def presenter
      @presenter ||=
        begin
          _, document_list = search_results(params, CatalogController.search_params_logic + [:find_one])
          curation_concern = document_list.first
          raise CanCan::AccessDenied.new(nil, params[:action].to_sym) unless curation_concern
          @presenter = show_presenter.new(curation_concern, current_ability)
        end
    end

    def manifest_builder
      PolymorphicManifestBuilder.new(presenter, ssl: request.ssl?, services: AuthManifestBuilder.auth_services(login_url, logout_url))
    end

    def login_url
      main_app.user_omniauth_authorize_url(:cas)
    end

    def logout_url
      current_user.nil? ? nil : main_app.destroy_user_session_url
    end

    def decorated_concern
      decorator.new(@curation_concern)
    end

    def decorator
      UpdatesMetadata
    end

    def wants_to_update_remote_metadata?
      params[:action] == "create" || params[:refresh_remote_metadata]
    end
end
# rubocop:enable Metrics/ClassLength
