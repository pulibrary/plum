class SammelbandLogicalOrder
  attr_reader :source_presenter, :source_structure
  delegate :file_presenters, to: :source_presenter
  def initialize(source_presenter, source_structure)
    @source_presenter = source_presenter
    @source_structure = source_structure
    @source_structure["nodes"] ||= []
  end

  def to_h
    @to_h ||= child_presenters.each_with_object(source_structure) do |presenter, hsh|
      found_node = find_node(presenter, hsh)
      if found_node
        found_node.delete("proxy")
        found_node["label"] = presenter.to_s
        found_node["nodes"] = (presenter.logical_order["nodes"] || canvas_ids(presenter))
      else
        hsh["nodes"] << {
          "label" => presenter.to_s,
          "nodes" => (presenter.logical_order["nodes"] || canvas_ids(presenter))
        }
      end
    end
  end

  private

    def find_node(presenter, top_node)
      top_node["nodes"].each do |node|
        return node if node["proxy"] == presenter.id
        if node["nodes"]
          found_node = find_node(presenter, node)
          return found_node if found_node
        end
      end
      nil
    end

    def canvas_ids(presenter)
      presenter.file_presenters.map do |file_presenter|
        {
          "proxy" => file_presenter.id
        }
      end
    end

    def child_presenters
      @child_presenters ||= file_presenters.select do |presenter|
        presenter.respond_to?(:logical_order)
      end
    end
end
