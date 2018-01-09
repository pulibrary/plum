# frozen_string_literal: true
class IngestWorkFromFileJob < ActiveJob::Base
  queue_as Hyrax.config.ingest_queue_name

  def perform(user, file_path, model)
    @model = model
    ingest_service.ingest_work(file_path, user)
  end

  private

    def ingest_service
      @ingest_service ||= ingest_service_class.new(logger)
    end

    def ingest_service_class
      @model == 'ImageWork' ? IngestScannedMapsService : IngestService
    end
end
