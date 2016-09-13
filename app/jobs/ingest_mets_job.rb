class IngestMETSJob < ActiveJob::Base
  queue_as :ingest

  # @param [String] mets_file Filename of a METS file to ingest
  # @param [String] user User to ingest as
  def perform(mets_file, user)
    logger.info "Ingesting METS #{mets_file}"
    @mets = METSDocument.new mets_file
    @user = user

    ingest
  end

  private

    def ingest
      resource = minimal_record(@mets.multi_volume? ? MultiVolumeWork : ScannedResource)
      resource.identifier = @mets.ark_id
      resource.replaces = @mets.pudl_id
      resource.source_metadata_identifier = @mets.bib_id
      resource.member_of_collections = Array(@mets.collection_slugs).map { |slug| find_or_create_collection(slug) }
      resource.apply_remote_metadata
      resource.save!
      logger.info "Created #{resource.class}: #{resource.id}"

      attach_mets resource

      if @mets.multi_volume?
        ingest_volumes(resource)
      else
        ingest_files(resource: resource, files: @mets.files)
        if @mets.structure.present?
          resource.logical_order.order = map_fileids(@mets.structure)
        end
        resource.save!
      end
    end

    def find_or_create_collection(slug)
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
      actor = FileSetActor.new(mets_file_set, @user)
      actor.attach_related_object(resource)
      actor.attach_content(File.open(@mets.source_file, 'r:UTF-8'))
    end

    def ingest_files(parent: nil, resource: nil, files: [])
      files.each do |f|
        logger.info "Ingesting file #{f[:path]}"
        file_set = FileSet.new
        file_set.title = [@mets.file_label(f[:id])]
        file_set.replaces = "#{@mets.pudl_id}/#{File.basename(f[:path], File.extname(f[:path]))}"
        actor = FileSetActor.new(file_set, @user)
        actor.create_metadata(resource, @mets.file_opts(f))
        actor.create_content(@mets.decorated_file(f))

        mets_to_repo_map[f[:id]] = file_set.id

        next unless f[:path] == @mets.thumbnail_path
        resource.thumbnail_id = file_set.id
        resource.save!
        parent.thumbnail_id = file_set.id if parent
      end
    end

    def ingest_volumes(parent)
      @mets.volume_ids.each do |volume_id|
        r = minimal_record(ScannedResource)
        r.title = [@mets.label_for_volume(volume_id)]
        r.save!
        logger.info "Created ScannedResource: #{r.id}"

        ingest_files(parent: parent, resource: r, files: @mets.files_for_volume(volume_id))
        r.logical_order.order = map_fileids(@mets.structure_for_volume(volume_id))
        r.save!

        parent.ordered_members << r
        parent.save!
      end
    end

    def minimal_record(klass)
      resource = klass.new
      resource.state = 'final_review'
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
