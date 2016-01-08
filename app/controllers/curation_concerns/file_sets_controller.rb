module CurationConcerns
  class FileSetsController < ApplicationController
    include CurationConcerns::FileSetsControllerBehavior

    def show_presenter
      ::FileSetPresenter
    end

    def after_update_response
      respond_to do |wants|
        wants.html do
          dest = parent_id.nil? ? [main_app, @file_set] : main_app.bulk_edit_curation_concerns_scanned_resource_path(parent_id)
          redirect_to dest, notice: "The file #{view_context.link_to(@file_set, [main_app, @file_set])} has been updated."
        end
        wants.json { render :show, status: :ok, location: polymorphic_path([main_app, @file_set]) }
      end
    end

    # this is provided so that implementing application can override this behavior and map params to different attributes
    def update_metadata
      file_attributes = ::FileSetEditForm.model_attributes(attributes)
      actor.update_metadata(file_attributes)
    end
  end
end
