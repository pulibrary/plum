class ManifestBuilder
  attr_reader :record
  delegate :to_json, to: :manifest

  def initialize(record)
    @record = record
    apply_record_properties
  end

  def manifest
    @manifest ||= IIIF::Presentation::Manifest.new
  end

  def canvases
    @canvases ||= canvas_builders.map(&:canvas)
  end

  private

    def path
      helper.curation_concerns_scanned_resource_manifest_url(record)
    end

    def canvas_builders
      record.file_presenters.map do |generic_file|
        CanvasBuilder.new(generic_file, path)
      end
    end

    def helper
      @helper ||= Rails.application.routes.url_helpers
    end

    def apply_record_properties
      manifest['@id'] = path
      manifest.label = record.to_s
      manifest.description = record.description
      manifest.viewing_hint = record.viewing_hint || "individuals"
      manifest.viewing_direction = record.viewing_direction || "left-to-right"
      sequence = IIIF::Presentation::Sequence.new
      sequence["@id"] = path + "/sequence/normal"
      sequence.viewing_hint = manifest.viewing_hint
      sequence.canvases += canvases
      manifest.sequences += [sequence]
    end
end
