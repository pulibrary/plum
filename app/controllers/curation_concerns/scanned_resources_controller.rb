# Generated via
#  `rails generate curation_concerns:work ScannedResource`

class CurationConcerns::ScannedResourcesController < CurationConcerns::CurationConcernsController
  include CurationConcerns::ParentContainer
  set_curation_concern_type ScannedResource
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

  def create
    super

    return unless parent_id
    parent = ActiveFedora::Base.find(parent_id, cast: true)
    parent.ordered_members << curation_concern.reload
    parent.save
    curation_concern.update_index
  end

  def show_presenter
    ScannedResourceShowPresenter
  end

  def pdf
    actor.generate_pdf
    redirect_to main_app.download_path(curation_concern, file: 'pdf')
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

  def browse_everything_files
    upload_set_id = ActiveFedora::Noid::Service.new.mint
    CompositePendingUpload.create(selected_files_params, curation_concern.id, upload_set_id)
    BrowseEverythingIngestJob.perform_later(curation_concern.id, upload_set_id, current_user, selected_files_params)
    redirect_to main_app.curation_concerns_scanned_resource_path(curation_concern)
  end

  def bulk_edit
    @members = presenter.file_presenters
  end

  def structure
    @members = presenter.file_presenters
    @logical_order = presenter.logical_order_object
  end

  def save_structure
    curation_concern.logical_order.order = { "nodes": params["nodes"] }
    curation_concern.save
    head 200
  end

  def form_class
    CurationConcerns::ScannedResourceForm
  end

  private

    def lock_manager
      @lock_manager ||= CurationConcerns::LockManager.new(
        CurationConcerns.config.lock_time_to_live,
        CurationConcerns.config.lock_retry_count,
        CurationConcerns.config.lock_retry_delay)
    end

    def selected_files_params
      params[:selected_files]
    end
end
