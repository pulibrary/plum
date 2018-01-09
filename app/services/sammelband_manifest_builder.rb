# frozen_string_literal: true
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

    def logical_order
      @logical_order ||= LogicalOrder.new(SammelbandLogicalOrder.new(record, record.logical_order).to_h)
    end

    class SammelbandViewingHint < SimpleDelegator
      def viewing_hint
        solr_document.viewing_hint || "individuals"
      end
    end
end
