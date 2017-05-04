class IngestExistingScannedMap < IngestScannedMapsService
  def ingest_map_record(map_record, file_path, user)
    @map = OpenStruct.new(map_record)
    delete_duplicates!("identifier_tesim:\"#{RSolr.solr_escape(full_ark)}\"") if @map.ark
    r = minimal_record choose_class, user, attributes
    members = [ingest_file(r, file_path, user, {}, file_set_attributes.merge(title: [image_id]))]
    fgdc_path = path_to_fgdc(file_path)
    members << ingest_file(r, fgdc_path, user, {}, metadata_attributes) if fgdc_path
    r.ordered_members = members
    r.save!
    GeoWorks::TriggerUpdateEvents.call(r)

    r
  end

  def minimal_record(klass, user, attributes)
    r = klass.new
    r.attributes = attributes
    r.apply_depositor_metadata user
    r.apply_remote_metadata if r.source_metadata_identifier
    r.id = ActiveFedora::Noid::Service.new.mint
    r.save!
    entity = Workflow::InitializeState.call(r, workflow_name, workflow_state)
    Workflow::InitializeComment.call(entity, user, comment) if comment
    @logger.info "Created #{klass}: #{r.id} #{attributes}"

    r
  end

  def full_ark
    "ark:/88435/#{@map.ark}"
  end

  def bib_id
    @map.bib_id || ''
  end

  def title
    @map.title || ''
  end

  def publisher
    @map.publisher || ''
  end

  def creator
    @map.author || ''
  end

  def description
    @map.pub_info || ''
  end

  def attributes
    bib_id.empty? ? attributes_no_bib_id : attributes_with_bib_id
  end

  def attributes_with_bib_id
    {
      identifier: [full_ark],
      replaces: [image_id],
      source_metadata_identifier: [bib_id],
      rights_statement: [rights_statement],
      visibility: visibility
    }
  end

  def attributes_no_bib_id
    {
      identifier: [full_ark],
      replaces: [image_id],
      title: [title],
      publisher: [publisher],
      creator: [creator],
      description: [description],
      rights_statement: [rights_statement],
      visibility: visibility
    }
  end

  def image_id
    "PUmap_#{@map.image_id}" if @map.image_id
  end

  def visibility
    if @map.copyright == 'f'
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    else
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
  end

  def rights_statement
    if @map.copyright == 'f'
      'http://rightsstatements.org/vocab/NKC/1.0/'
    else
      'http://rightsstatements.org/vocab/InC/1.0/'
    end
  end

  def workflow_state
    if bib_id.empty?
      'pending'
    elsif @map.bbox == 'f'
      'metadata_review'
    else
      'complete'
    end
  end

  def comment
    if bib_id.empty?
      'Scanned map is missing a Voyager bibid.'
    elsif @map.bbox == 'f'
      'MARC record is missing bounding box or has an incorrectly formatted bounding box.'
    end
  end

  def path_to_fgdc(tiff_file_path)
    base = /(.*\/)/.match(tiff_file_path)[0]
    path = "#{base}fgdc.xml"
    path if File.exist?(path)
  end

  def metadata_attributes
    { geo_mime_type: 'application/xml; schema=fgdc', title: ['fgdc.xml'] }
  end
end
