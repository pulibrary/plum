class ManifestBuilder
  attr_reader :record, :light
  delegate :to_json, to: :manifest

  def initialize(record, light = false)
    @record = record
    @light = light
    apply_record_properties
  end

  def manifest
    @manifest ||= manifest_builder_class
  end

  def canvases
    @canvases ||= canvas_builders.map(&:canvas)
  end

  def manifests
    @manifests ||= manifest_builders.map(&:manifest)
  end

  private

    def manifest_builder_class
      if manifest_builders.length > 0
        IIIF::Presentation::Collection.new
      else
        IIIF::Presentation::Manifest.new
      end
    end

    def path
      helper.__send__(:"curation_concerns_#{record.model_name.singular}_manifest_url", record)
    end

    def canvas_builders
      file_set_presenters.map do |generic_file|
        CanvasBuilder.new(generic_file, path)
      end
    end

    def file_set_presenters
      record.file_presenters.select do |x|
        x.model_name.name == "FileSet"
      end
    end

    def manifest_builders
      manifest_presenters.map do |model|
        ManifestBuilder.new(model, true)
      end
    end

    def manifest_presenters
      record.file_presenters - file_set_presenters
    end

    def helper
      @helper ||= Rails.application.routes.url_helpers
    end

    def apply_record_properties
      manifest['@id'] = path
      manifest.label = record.to_s
      manifest.description = record.description
      manifest.viewing_hint = record.viewing_hint || "individuals"
      if manifest.respond_to?(:viewing_direction)
        manifest.viewing_direction = record.try(:viewing_direction) || "left-to-right"
      end
      apply_canvases unless light
      apply_manifests if manifests.length > 0
    end

    def apply_canvases
      return if canvases.length == 0
      sequence = IIIF::Presentation::Sequence.new
      sequence["@id"] = path + "/sequence/normal"
      sequence.viewing_hint = manifest.viewing_hint
      sequence.canvases += canvases
      manifest.sequences += [sequence]
    end

    def apply_manifests
      manifest['manifests'] = manifests
    end
end
