class IngestScannedMapsService < IngestService
  def ingest_dir(dir, user)
    Dir["#{dir}/*"].sort.each do |f|
      ingest_work(f, user)
    end
  end

  def ingest_work(file_path, user)
    klass = choose_class
    bib_id = File.basename(file_path, '.*')
    attribs = { source_metadata_identifier: bib_id }
    r = minimal_record klass, user, attribs
    members = [ingest_file(r, file_path, user, {}, file_set_attributes.merge(title: [bib_id]))]
    r.ordered_members = members
    r.save!
    r
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
