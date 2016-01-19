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
      @logical_order ||= LogicalOrder.new(combined_logical_order)
    end

    def combined_logical_order
      range_presenters.each_with_object("nodes" => []) do |presenter, hsh|
        hsh["nodes"] << {
          "label" => presenter.to_s,
          "nodes" => (presenter.logical_order["nodes"] || canvas_ids(presenter))
        }
      end
    end

    def canvas_ids(presenter)
      presenter.file_presenters.map do |file_presenter|
        {
          "proxy" => file_presenter.id
        }
      end
    end

    def range_presenters
      record.file_presenters.select do |presenter|
        !presenter.try(:logical_order).nil?
      end
    end

    class SammelbandViewingHint < SimpleDelegator
      def viewing_hint
        "individuals"
      end
    end
end
