class CurationConcerns::CurationConcernsController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::Collectible
  include CurationConcerns::Manifest
  include CurationConcerns::MemberManagement
  include CurationConcerns::UpdateOCR
  include CurationConcerns::RemoteMetadata

  def curation_concern_name
    curation_concern.class.name.underscore
  end

  def update
    authorize!(:complete, curation_concern, message: 'Unable to mark resource complete') if curation_concern.state != 'complete' && params[curation_concern_name][:state] == 'complete'
    add_to_collections(params[curation_concern_name].delete(:collection_ids))
    super
  end

  def destroy
    messenger.record_deleted(curation_concern)
    super
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
    redirect_to polymorphic_path([main_app, :file_manager, curation_concern])
  end

  def after_create_response
    send_record_created
    super
  end

  def send_record_created
    messenger.record_created(curation_concern)
  end

  private

    def messenger
      @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
    end

    def curation_concern
      @decorated_concern ||=
        begin
          @curation_concern = decorator.new(@curation_concern)
        end
    end

    def decorator
      CompositeDecorator.new(super, NullDecorator)
    end

    def selected_files_params
      params[:selected_files]
    end
end
