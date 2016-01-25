class CurationConcerns::CurationConcernsController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::Collectible
  include CurationConcerns::Manifest
  include CurationConcerns::MemberManagement
  include CurationConcerns::RemoteMetadata

  def curation_concern_name
    curation_concern.class.name.underscore
  end

  def update
    authorize!(:complete, @curation_concern, message: 'Unable to mark resource complete') if @curation_concern.state != 'complete' && params[curation_concern_name][:state] == 'complete'
    add_to_collections(params[curation_concern_name].delete(:collection_ids))
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
    redirect_to polymorphic_path([main_app, :bulk_edit, curation_concern])
  end

  private

    def selected_files_params
      params[:selected_files]
    end
end
