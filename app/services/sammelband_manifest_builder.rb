class SammelbandManifestBuilder < ManifestBuilder
  def record
    @decorated_record ||= SammelbandViewingHint.new(super)
  end

  private

    def canvas_builder_factory
      ::SammelbandManifestBuilder::SammelbandCanvasBuilderFactory
    end

    def manifest_builders
      @manifest_builders ||= CompositeBuilder.new
    end

    class SammelbandViewingHint < SimpleDelegator
      def viewing_hint
        "individuals"
      end
    end
end
