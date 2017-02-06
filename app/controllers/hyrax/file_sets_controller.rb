module Hyrax
  class FileSetsController < ApplicationController
    include Hyrax::FileSetsControllerBehavior
    # include GeoConcerns::FileSetsControllerBehavior

    def show_presenter
      ::FileSetPresenter
    end

    def after_update_response(msg = nil)
      respond_to do |wants|
        wants.html do
          msg = "The file #{view_context.link_to(@file_set, [main_app, @file_set])} has been updated." unless msg
          dest = parent.nil? ? [main_app, @file_set] : [main_app, :file_manager, parent]
          redirect_to dest, notice: msg
        end
        wants.json do
          @presenter = show_presenter.new(curation_concern, current_ability)
          render :show, status: :ok, location: polymorphic_path([main_app, curation_concern])
        end
      end
    end

    # this is provided so that implementing application can override this behavior and map params to different attributes
    def update_metadata
      file_attributes = ::FileSetEditForm.model_attributes(attributes)
      actor.update_metadata(file_attributes)
    end

    def text
      respond_to do |f|
        f.json do
          render json: annotation_builder
        end
      end
    end

    def derivatives
      CreateDerivativesJob.perform_later(file_set, file_set.send(:original_file).id)
      after_update_response "Regenerating derivatives for #{view_context.link_to(@file_set, [main_app, @file_set])}"
    end

    protected

      def actor
        @actor ||= ::FileSetActor.new(@file_set, current_user)
      end

      def annotation_builder
        AnnotationListBuilder.new(@file_set, main_app.text_hyrax_member_file_set_url(parent, @file_set), CanvasID.new(@file_set.id, polymorphic_url([main_app, :manifest, parent])).to_s)
      end
  end
end
