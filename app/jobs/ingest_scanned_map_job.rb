class IngestScannedMapJob < ApplicationJob
  queue_as :ingest

  # @param [OpenStruct] map_record
  # @param [String] user User to ingest as
  def perform(map_record, file_path, user)
    logger.info "Ingesting Scanned Map #{map_record.ark}"
    ingest_service = ::IngestExistingScannedMap.new(logger)
    ingest_service.ingest_map_record(map_record, file_path, user)
  end
end
