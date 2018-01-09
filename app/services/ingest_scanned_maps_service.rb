# frozen_string_literal: true
class IngestScannedMapsService < IngestService
  def ingest_dir(dir, user)
    Dir["#{dir}/*"].sort.each do |f|
      ingest_work(f, user)
    end
  end

  def workflow_name
    'geo_works'
  end

  def choose_class(_file = nil)
    ImageWork
  end

  def file_set_attributes
    { geo_mime_type: 'image/tiff' }
  end
end
