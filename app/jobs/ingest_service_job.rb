class IngestServiceJob < ApplicationJob
  queue_as :ingest

  def perform(dir, bib, user, coll_id)
    coll = ActiveFedora::Base.find(coll_id)
    IngestService.new(@logger).ingest_dir dir, bib, user, coll
  end
end
