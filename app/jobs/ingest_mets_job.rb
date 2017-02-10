require 'new_relic/agent/method_tracer'
class IngestMETSJob < ApplicationJob
  include ::NewRelic::Agent::MethodTracer
  queue_as :ingest

  # @param [String] mets_file Filename of a METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting METS #{mets_file}"
    @mets = METSDocument::Factory.new(mets_file).new
    @user = user

    ingest
  end

  private

    def ingest
      delete_duplicates!
      resource = minimal_record(@mets.multi_volume? ? MultiVolumeWork : ScannedResource)
      resource.identifier = @mets.ark_id
      resource.replaces = @mets.pudl_id
      resource.source_metadata_identifier = @mets.bib_id
      resource.member_of_collections = Array(@mets.collection_slugs).select(&:present?).map { |slug| find_or_create_collection(slug) }
      resource.apply_remote_metadata
      resource.save!
      Workflow::InitializeState.call(resource, 'book_works', 'final_review')
      logger.info "Created #{resource.class}: #{resource.id}"

      attach_mets resource

      if @mets.multi_volume?
        ingest_volumes(resource)
      else
        resource.viewing_hint = @mets.viewing_hint
        ingest_files(resource: resource, files: @mets.files)
        if @mets.structure.present?
          resource.logical_order.order = map_fileids(@mets.structure)
        end
        resource.save!
        validate!(resource)
      end
    end

    def validate!(resource)
      return if @mets.files.length == resource.member_ids.length
      logger.info "Incorrect number of files ingested for #{resource.id}: #{resource.member_ids.length} of expected #{@mets.files.length}"
    end

    def delete_duplicates!
      old_resources = old_resource_ids.map { |x| ActiveFedora::Base.find(x) }
      old_resources.each do |resource|
        logger.info "Deleting existing resource with ID of #{resource.id} which had ARK #{@mets.ark_id}"
        resource.destroy
      end
    end

    def old_resource_ids
      ActiveFedora::SolrService.query("identifier_ssim:#{RSolr.solr_escape(@mets.ark_id)}", fl: "id").map { |x| x["id"] }
    end

    def find_or_create_collection(slug)
      return unless slug.present?
      existing = Collection.where exhibit_id_ssim: slug
      return existing.first if existing.first
      col = Collection.new metadata_for_collection(slug)
      col.apply_depositor_metadata @user
      col.save!
      col
    end

    def metadata_for_collection(slug)
      collection_metadata.each do |c|
        return { exhibit_id: slug, title: [c['title']], description: [c['blurb']] } if c['slug'] == slug
      end
    end

    def collection_metadata
      @collection_metadata ||= JSON.parse(File.read(File.join(Rails.root, 'config', 'pudl_collections.json')))
    end

    def attach_mets(resource)
      mets_file_set = FileSet.new
      mets_file_set.title = ['METS XML']
      actor = BatchFileSetActor.new(mets_file_set, @user)
      actor.attach_related_object(resource)
      actor.attach_content(File.open(@mets.source_file, 'r:UTF-8'))
    end

    def ingest_files(parent: nil, resource: nil, files: [])
      ordered_members = []
      files.each do |f|
        file_set = ingest_file(parent: parent, resource: resource, f: f)
        ordered_members << file_set if file_set
      end

      resource.ordered_members = ordered_members
    end

    def ingest_file(parent: nil, resource: nil, f: nil, count: 0)
      logger.info "Ingesting file #{f[:path]}"
      file_set = FileSet.new
      file_set.title = [@mets.file_label(f[:id])]
      file_set.replaces = f[:replaces]
      actor = BatchFileSetActor.new(file_set, @user)
      actor.create_metadata(resource, @mets.file_opts(f))
      actor.create_content(@mets.decorated_file(f))

      mets_to_repo_map[f[:id]] = file_set.id

      if f[:path] == @mets.thumbnail_path
        resource.thumbnail_id = file_set.id
        resource.save!
        parent.thumbnail_id = file_set.id if parent
      end

      return file_set
    rescue StandardError => e
      raise e if count > 4
      count += 1
      logger.info "Failed ingesting #{f[:path]} #{count} times, retrying. Error: #{e.message}"
      return ingest_file(parent: parent, resource: resource, f: f, count: count)
    end

    add_method_tracer :ingest_file, 'IngestMETSJob/ingest_file'

    def ingest_volumes(parent)
      @mets.volume_ids.each do |volume_id|
        r = minimal_record(ScannedResource)
        r.title = [@mets.label_for_volume(volume_id)]
        r.viewing_hint = @mets.viewing_hint
        r.save!
        Workflow::InitializeState.call(r, 'book_works', 'final_review')
        logger.info "Created ScannedResource: #{r.id}"

        parent.ordered_members << r
        parent.save!

        ingest_files(parent: parent, resource: r, files: @mets.files_for_volume(volume_id))
        r.logical_order.order = map_fileids(@mets.structure_for_volume(volume_id))
        r.thumbnail_id = r.file_sets.first.id unless r.thumbnail_id
        r.save!
      end
    end

    def minimal_record(klass)
      resource = klass.new
      resource.viewing_direction = @mets.viewing_direction
      resource.rights_statement = 'http://rightsstatements.org/vocab/NKC/1.0/'
      resource.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      resource.apply_depositor_metadata @user
      resource
    end

    def map_fileids(hsh)
      hsh.each do |k, v|
        hsh[k] = v.each { |node| map_fileids(node) } if k == :nodes
        hsh[k] = mets_to_repo_map[v] if k == :proxy
      end
    end

    def mets_to_repo_map
      @mets_to_repo_map ||= {}
    end
end
