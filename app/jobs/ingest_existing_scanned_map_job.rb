# frozen_string_literal: true
class IngestExistingScannedMapJob < ApplicationJob
  queue_as :ingest

  # @param [Hash] map_record as hash
  # @param [String] user User to ingest as
  def perform(map_record, file_path, user)
    ark = map_record.fetch('ark')
    logger.info "Ingesting Scanned Map #{ark}"
    ingest_service = ::IngestExistingScannedMap.new(logger)
    ingest_service.ingest_map_record(map_record, file_path, user)
  end
end
