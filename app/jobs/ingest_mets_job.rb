require 'new_relic/agent/method_tracer'
class IngestMETSJob < ApplicationJob
  include ::NewRelic::Agent::MethodTracer
  queue_as :ingest

  # @param [String] mets_file Filename of a METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting METS #{mets_file}"
    @ingest = IngestService.new(logger)
    @mets = METSDocument::Factory.new(mets_file).new
    @user = user

    ingest
  end

  private

    def ingest
      if @mets.multi_volume?
        volumes = ingest_volumes
        mvw = create_resource
        mvw.ordered_members = volumes
        mvw.thumbnail_id = volumes.first.thumbnail_id
        mvw.save!

        volumes.each(&:update_index)
      else
        resource = create_resource
        ingest_files(resource: resource, files: @mets.files)
        if @mets.structure.present?
          resource.logical_order.order = map_fileids(@mets.structure)
        end
        resource.viewing_hint = [@mets.viewing_hint] if @mets.viewing_hint
        resource.save!
        validate!(resource)
      end
    end

    def create_resource
      @ingest.delete_duplicates!("identifier_ssim:#{RSolr.solr_escape(@mets.ark_id)}")
      klass = @mets.multi_volume? ? MultiVolumeWork : ScannedResource
      cols = Array(@mets.collection_slugs).select(&:present?).map { |slug| find_or_create_collection(slug) }
      resource = @ingest.minimal_record(klass, @user, viewing_direction: [@mets.viewing_direction],
                                                      identifier: [@mets.ark_id],
                                                      replaces: [@mets.pudl_id],
                                                      source_metadata_identifier: [@mets.bib_id],
                                                      member_of_collections: cols)
      attach_mets resource
      resource
    end

    def validate!(resource)
      return if @mets.files.length == resource.member_ids.length
      logger.info "Incorrect number of files ingested for #{resource.id}: #{resource.member_ids.length} of expected #{@mets.files.length}"
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
      raise StandardError, "No collection metadata found for slug '#{slug}'"
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

    def ingest_files(resource: nil, files: [])
      ordered_members = []
      files.each do |f|
        file_set = ingest_file(resource: resource, f: f)
        ordered_members << file_set if file_set
      end

      resource.ordered_members = ordered_members
    end

    def ingest_file(resource: nil, f: nil, count: 0)
      file_set = @ingest.ingest_file(resource, @mets.decorated_file(f), @user, @mets.file_opts(f),
                                     title: [@mets.file_label(f[:id])], replaces: [f[:replaces]])
      mets_to_repo_map[f[:id]] = file_set.id

      if f[:path] == @mets.thumbnail_path
        resource.thumbnail_id = file_set.id
        resource.save!
      end

      return file_set
    rescue StandardError => e
      raise e if count > 4
      count += 1
      logger.info "Failed ingesting #{f[:path]} #{count} times, retrying. Error: #{e.message}"
      return ingest_file(resource: resource, f: f, count: count)
    end

    add_method_tracer :ingest_file, 'IngestMETSJob/ingest_file'

    def ingest_volumes
      @mets.volume_ids.map do |volume_id|
        r = find_volume("#{@mets.pudl_id}/#{volume_id}")
        if r
          logger.info "Found existing volume: #{r.id}"
        else
          r = @ingest.minimal_record(ScannedResource, @user, title: [@mets.label_for_volume(volume_id)])
          ingest_files(resource: r, files: @mets.files_for_volume(volume_id))
        end

        r.logical_order.order = map_fileids(@mets.structure_for_volume(volume_id))
        r.thumbnail_id = r.file_sets.first.id unless r.thumbnail_id
        r.title = [@mets.label_for_volume(volume_id)]
        r.viewing_direction = [@mets.viewing_direction]
        r.viewing_hint = [@mets.viewing_hint] if @mets.viewing_hint
        r.save!

        r
      end
    end

    def find_volume(replaces)
      solr_rec = ActiveFedora::SolrService.query("replaces_ssim:#{replaces}").first
      ActiveFedora::Base.find(solr_rec['id']) if solr_rec
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
