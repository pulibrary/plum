class ManifestBuilder
  attr_reader :record, :services
  delegate :to_json, to: :manifest

  def initialize(record, ssl: false, services: nil)
    @record = record
    @ssl = ssl
    @services = CompositeBuilder.new(*Array.wrap(services))
    builders.apply(manifest)
  end

  def manifest
    @manifest ||= manifest_builder_class
  end

  def manifests
    @manifests ||= manifest_builders.manifest
  end

  def canvases
    canvas_builders.canvas
  end

  def root_path
    @root_path ||= ManifestPath.new(record, ssl: @ssl)
  end

  def apply(manifest)
    manifest['manifests'] ||= []
    manifest['manifests'] += [self.manifest]
  end

  private

    def builders
      @builders ||=
        CompositeBuilder.new(
          record_property_builder,
          services,
          sequence_builder,
          range_builder,
          manifest_builders,
          pdf_link_builder,
          metadata_builder,
          thumbnail_builder,
          see_also_builder,
          logo_builder,
          license_builder,
          rendering_builder
        )
    end

    def record_property_builder
      RecordPropertyBuilder.new(record, root_path)
    end

    def pdf_link_builder
      PDFLinkBuilder.new(record, ssl: @ssl)
    end

    def thumbnail_builder
      ThumbnailBuilder.new(record, canvas_builders)
    end

    def metadata_builder
      MetadataBuilder.new(record)
    end

    def sequence_builder
      SequenceBuilder.new(root_path, canvas_builders, start_canvas_builder)
    end

    def see_also_builder
      SeeAlsoBuilder.new(record)
    end

    def logo_builder
      LogoBuilder.new(ssl: @ssl)
    end

    def license_builder
      LicenseBuilder.new(record)
    end

    def rendering_builder
      RenderingBuilder.new(record)
    end

    def manifest_builder_class
      if manifest_builders.length > 0
        IIIF::Presentation::Collection.new
      else
        IIIF::Presentation::Manifest.new
      end
    end

    def canvas_builders
      @canvas_builders ||= canvas_builder_factory.new(record).new(root_path)
    end

    def canvas_builder_factory
      ::ManifestBuilder::CanvasBuilderFactory
    end

    def manifest_builders
      @manifest_builders ||= ManifestBuilderFactory.new(record, child_factory: child_manifest_factory, ssl: @ssl).new
    end

    def child_manifest_factory
      ChildManifestBuilder
    end

    def range_builder
      RangeBuilder.new(logical_order, root_path, top: true)
    end

    def logical_order
      @logical_order ||= LogicalOrder.new(record.logical_order)
    end

    def start_canvas_builder
      StartCanvasBuilder.new(record, canvas_builders)
    end
end
