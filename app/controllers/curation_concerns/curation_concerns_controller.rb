class CurationConcerns::CurationConcernsController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::Manifest
  include CurationConcerns::MemberManagement
  include CurationConcerns::UpdateOCR
  include CurationConcerns::RemoteMetadata
  include CurationConcerns::Flagging

  def curation_concern_name
    curation_concern.class.name.underscore
  end

  def update
    authorize!(:complete, curation_concern, message: 'Unable to mark resource complete') if curation_concern.state != 'complete' && params[curation_concern_name][:state] == 'complete'
    super
  end

  def destroy
    messenger.record_deleted(curation_concern)
    super
  end

  def file_manager
    parent_presenter
    super
  end

  def browse_everything_files
    upload_set_id = ActiveFedora::Noid::Service.new.mint
    CompositePendingUpload.create(selected_files_params, curation_concern.id, upload_set_id)
    BrowseEverythingIngestJob.perform_later(curation_concern.id, upload_set_id, current_user, selected_files_params)
    redirect_to ::ContextualPath.new(curation_concern, parent_presenter).file_manager
  end

  def after_create_response
    send_record_created
    super
  end

  def send_record_created
    messenger.record_created(curation_concern)
  end

  private

    def search_builder_class
      ::WorkSearchBuilder
    end

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
