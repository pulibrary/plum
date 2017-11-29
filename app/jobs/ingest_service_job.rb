# frozen_string_literal: true
class IngestServiceJob < ApplicationJob
  queue_as :ingest

  def perform(dir, bib, user, params)
    IngestService.new(@logger).ingest_dir dir, bib, user, params
  end
end
