class IngestExistingScannedMap < IngestScannedMapsService
  def ingest_map_record(map_record, file_path, user)
    @map = map_record
    delete_duplicates!("identifier_ssim:#{RSolr.solr_escape(ark)}") if @map.ark
    r = minimal_record choose_class, user, attributes
    members = [ingest_file(r, file_path, user, {}, file_set_attributes.merge(title: [image_id]))]
    r.ordered_members = members
    r.save!

    r
  end

  def ark
    "ark:/88435/#{@map.ark}"
  end

  def minimal_record(klass, user, attributes)
    r = klass.new
    r.attributes = attributes
    r.apply_depositor_metadata user
    r.apply_remote_metadata if r.source_metadata_identifier
    r.save!
    apply_work_flow(r)
    @logger.info "Created #{klass}: #{r.id} #{attributes}"

    r
  end

  def attributes
    @map.bib_id.empty? ? attributes_no_bib_id : attributes_with_bib_id
  end

  def attributes_with_bib_id
    {
      identifier: ark,
      replaces: image_id,
      source_metadata_identifier: @map.bib_id,
      rights_statement: rights_statement,
      visibility: visibility
    }
  end

  def attributes_no_bib_id
    {
      identifier: ark,
      replaces: image_id,
      title: [@map.title],
      publisher: [@map.publisher],
      creator: [@map.author],
      description: [@map.pub_info, @map.pub_date],
      rights_statement: rights_statement,
      visibility: visibility
    }
  end

  def image_id
    "PU_#{@map.image_id}" if @map.image_id
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

  def apply_work_flow(record)
    Workflow::InitializeState.call(record, workflow_name, workflow_state)
  end

  def workflow_state
    if @map.bbox == 'f'
      'metadata_review'
    elsif @map.bib_id.empty?
      'pending'
    else
      'complete'
    end
  end

  def file_set_attributes
    {
      visibility: visibility,
      geo_mime_type: 'image/tiff'
    }
  end
end
