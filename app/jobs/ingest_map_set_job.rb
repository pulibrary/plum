class IngestMapSetJob < ApplicationJob
  queue_as :ingest

  # @param [Hash] map_record as hash
  # @param [String] user User to ingest as
  def perform(map_record, base_file_path, user)
    bibid = map_record.fetch('bibid')
    logger.info "Ingesting Map Set #{bibid}"
    ingest_service = ::IngestMapSetService.new(logger)
    ingest_service.ingest_map_set(map_record, base_file_path, user)
  end
end
