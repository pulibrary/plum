# rubocop:disable Metrics/ClassLength
class IngestYAMLJob < ActiveJob::Base
  include CollectionHelper
  include CurationConcerns::Lockable

  queue_as :ingest

  # @param [String] yaml_file Filename of a YAML file to ingest
  # @param [String] user User to ingest as
  def perform(yaml_file, user, file_association_method: 'batch')
    logger.info "Ingesting YAML #{yaml_file}"
    @yaml_file = yaml_file
    @yaml = File.open(yaml_file) { |f| Psych.load(f) }
    @user = user
    @file_association_method = file_association_method
    ingest
  end

  private

    def ingest
      @counter = IngestCounter.new
      resource = (@yaml[:volumes].present? ? MultiVolumeWork : ScannedResource).new
      if @yaml[:attributes].present?
        @yaml[:attributes].each { |_set_name, attributes| resource.attributes = attributes }
      end
      resource.source_metadata = @yaml[:source_metadata] if @yaml[:source_metadata].present?

      resource.apply_depositor_metadata @user
      resource.member_of_collections = find_or_create_collections(@yaml[:collections])

      resource.save!
      logger.info "Created #{resource.class}: #{resource.id}"

      attach_sources resource

      if @yaml[:volumes].present?
        ingest_volumes(resource)
      else
        ingest_files(resource: resource, files: @yaml[:files])
        if @yaml[:structure].present?
          resource.logical_order.order = map_fileids(@yaml[:structure])
        end
        resource.save!
      end

      resource.state = 'complete'
      resource.save!
    end

    def attach_sources(resource)
      return unless @yaml[:sources].present?
      @yaml[:sources].each do |source|
        attach_source(resource, source[:title], source[:file])
      end
    end

    def attach_source(resource, title, file)
      file_set = FileSet.new
      file_set.title = title
      actor = FileSetActor.new(file_set, @user)
      actor.attach_related_object(resource)
      actor.attach_content(File.open(file, 'r:UTF-8'))
    end

    def ingest_volumes(parent)
      @volumes = []
      @yaml[:volumes].each do |volume|
        r = ScannedResource.new
        r.attributes = @yaml[:attributes][:default] if @yaml[:attributes].present? && @yaml[:attributes][:default].present?
        r.attributes = volume[:attributes] if volume[:attributes].present?
        r.viewing_direction = parent.viewing_direction
        r.title = volume[:title]
        r.apply_depositor_metadata @user
        r.save!
        logger.info "Created ScannedResource: #{r.id}"

        ingest_files(parent: parent, resource: r, files: volume[:files])
        r.logical_order.order = map_fileids(volume[:structure])
        r.state = 'complete'
        r.save!
        @volumes << r
      end
      parent.ordered_members = @volumes
      parent.save!
    end

    def ingest_files(parent: nil, resource: nil, files: [])
      @file_sets = []
      files.each do |f|
        logger.info "Ingesting file #{f[:path]}"
        @counter.increment
        file_set = FileSet.new
        file_set.attributes = f[:attributes]
        actor = FileSetActor.new(file_set, @user)
        if @file_association_method.in? ['batch', 'none']
          actor.create_metadata(nil, f[:file_opts])
        else
          actor.create_metadata(resource, f[:file_opts])
        end
        actor.assign_visibility(resource) unless assign_visibility?(f[:attributes])
        actor.create_content(decorated_file(f))
        ingest_ocr(actor, f)

        yaml_to_repo_map[f[:id]] = file_set.id
        @file_sets << file_set if @file_association_method == 'batch'
        ingest_thumbnail(file_set, resource, parent) if thumbnail_path?(f[:path])
      end
      MembershipBuilder.new(resource, @file_sets).attach_files_to_work if @file_sets.any?
    end

    def ingest_ocr(actor, f)
      return unless ocr_file?(f)
      ocr_file = File.open(f[:ocr_path])
      actor.create_content(ocr_file, "extracted_text")
      ocr_file.close
    end

    def ingest_thumbnail(file_set, resource, parent)
      resource.thumbnail_id = file_set.id
      resource.representative_id = file_set.id
      resource.save!
      parent.thumbnail_id = file_set.id if parent
      parent.representative_id = file_set.id if parent
    end

    def decorated_file(f)
      IoDecorator.new(open(f[:path]), f[:mime_type], File.basename(f[:path]))
    end

    def ocr_file?(f)
      (f.key?(:ocr_path) && File.exist?(f[:ocr_path])) ? true : false
    end

    def map_fileids(hsh)
      hsh.each do |k, v|
        hsh[k] = v.each { |node| map_fileids(node) } if k == :nodes
        hsh[k] = yaml_to_repo_map[v] if k == :proxy
      end
    end

    def yaml_to_repo_map
      @yaml_to_repo_map ||= {}
    end

    def thumbnail_path
      @thumbnail_path ||= @yaml[:thumbnail_path]
    end

    def thumbnail_path?(path)
      thumbnail_path.present? && thumbnail_path == path
    end

    # Purloined from FileSetActor, unmodified
    def assign_visibility?(file_set_params = {})
      !((file_set_params || {}).keys & %w(visibility embargo_release_date lease_expiration_date)).empty?
    end
end
# rubocop:enable Metrics/ClassLength
