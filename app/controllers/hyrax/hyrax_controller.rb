class Hyrax::HyraxController < ApplicationController
  include Hyrax::WorksControllerBehavior
  include Hyrax::Manifest
  include Hyrax::MemberManagement
  include Hyrax::UpdateOCR
  include Hyrax::RemoteMetadata

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
    respond_to do |wants|
      wants.html do
        # Calling `#t` in a controller context does not mark _html keys as html_safe
        flash[:notice] = view_context.t('hyrax.works.new.after_create_html', application_name: view_context.application_name)
        redirect_to contextual_path(curation_concern, parent_presenter)
      end
      wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
    end
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
      return nil unless @curation_concern
      @decorated_concern ||=
        begin
          @curation_concern = decorator.new(@curation_concern)
        end
    end

    def decorator
      CompositeDecorator.new(super, NullDecorator)
    end

    def selected_files_params
      params[:selected_files].to_unsafe_h
    end
end
