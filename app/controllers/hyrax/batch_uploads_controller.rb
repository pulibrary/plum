class Hyrax::BatchUploadsController < ApplicationController
  include Hyrax::BatchUploadsControllerBehavior

  # Gives the class of the form.
  class BatchUploadFormService < Hyrax::WorkFormService
    def self.form_class(_ = nil)
      ::Hyrax::BatchUploadForm
    end
  end

  self.work_form_service = BatchUploadFormService

  protected

    def create_update_job(klass)
      BatchCreateJob.perform_later(current_user,
                                   params[:uploaded_files],
                                   attributes_for_actor.to_h.merge!(model: klass))
    end
end
