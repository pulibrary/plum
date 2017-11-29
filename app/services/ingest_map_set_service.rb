# frozen_string_literal: true
class IngestMapSetService < IngestScannedMapsService
  attr_reader :record, :base_file_path, :user

  def ingest_map_set(record, base_file_path, user)
    @record = record
    @base_file_path = base_file_path
    @user = user

    delete_duplicates!("source_metadata_identifier_tesim:\"#{RSolr.solr_escape(record['bibid'])}\"") if record['bibid']
    map_set = create_map_set
    members = create_map_set_members
    map_set.ordered_members = members
    map_set.save!
  end

  def minimal_record(klass, user, attributes)
    default_attributes = { rights_statement: ['http://rightsstatements.org/vocab/NKC/1.0/'],
                           visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    r = klass.new
    r.attributes = default_attributes.merge(attributes)
    r.apply_depositor_metadata user
    r.apply_remote_metadata if r.source_metadata_identifier
    r.id = ActiveFedora::Noid::Service.new.mint
    r.save!
    Workflow::InitializeState.call(r, workflow_name, workflow_state(klass))
    @logger.info "Created #{klass}: #{r.id} #{attributes}"

    r
  end

  def workflow_state(klass)
    klass == MapSet ? 'final_review' : 'complete'
  end

  def ingest_work(file_path, ark, title, sheet_title)
    klass = ImageWork
    bib_id = record['bibid']
    attribs = { source_metadata_identifier: [bib_id], identifier: ["ark:/88435/#{ark}"] }
    r = minimal_record klass, user, attribs
    r.source_metadata_identifier = []
    members = [ingest_file(r, file_path, user, {}, file_set_attributes.merge(title: [sheet_title]))]
    r.ordered_members = members
    r.save!

    update_image_work_title(r.id, title)
  end

  def update_image_work_title(id, title)
    r = ImageWork.find(id)
    r.title = [title]
    r.save!

    r
  end

  def create_map_set_members
    members = []
    record['members'].each do |member_record|
      ark = member_record['ark']
      title = member_record['title']
      page = member_record['page']
      sheet_title = generate_title(page)
      delete_duplicates!("identifier_tesim:\"#{RSolr.solr_escape("ark:/88435/#{ark}")}\"") if ark
      file_path = path_to_tiff(ark)
      next unless File.exist?(file_path)
      work = ingest_work(file_path, ark, title, sheet_title)
      members << work if work
    end

    members
  end

  def create_map_set
    klass = MapSet
    bib_id = record['bibid']
    attribs = { source_metadata_identifier: [bib_id] }
    r = minimal_record klass, user, attribs
    r.save!

    r
  end

  def generate_title(page)
    if page == 0
      'Title'
    elsif page == 1
      'Overview'
    elsif page == 2
      'Index'
    else
      generate_sheet_num(page)
    end
  end

  def generate_sheet_num(page)
    sheet_num = page - 2
    "Sheet #{sheet_num}"
  end

  def path_to_tiff(noid)
    path = ''
    noid.scan(/.{1,2}/).each { |seg| path << '/' + seg }
    "#{base_file_path}#{path}/#{noid}.tif"
  end
end
