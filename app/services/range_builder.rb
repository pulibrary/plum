class RangeBuilder
  attr_reader :node, :parent_path, :top
  def initialize(node, parent_path, top: false, label: nil)
    @node = node
    @parent_path = parent_path
    @top = top
    @label = label
  end

  def label
    @label || node.label
  end

  def to_h
    build_range
  end

  def apply(manifest)
    manifest['structures'] = [to_h] unless nodes.empty?
  end

  private

    def build_range
      range = IIIF::Presentation::Range.new
      range.label = label
      range['@id'] = path
      range.viewing_hint = "top" if top
      unless regular_nodes.empty?
        range['ranges'] = regular_nodes.map { |x| self.class.new(x, parent_path).to_h }
      end
      unless proxy_nodes.empty?
        range['canvases'] = proxy_nodes.map do |proxy_node|
          canvas_id(proxy_node.proxy_for_id)
        end
      end
      range
    end

    def nodes
      node.nodes
    end

    def path
      "#{parent_path}/range/#{node.id.delete('#')}"
    end

    def proxy_nodes
      @proxy_nodes ||= nodes.select { |x| x.proxy_for.present? }
    end

    def regular_nodes
      @regular_nodes ||= nodes.select { |x| !x.proxy_for.present? && x.nodes.length > 0 }
    end

    def canvas_id(id)
      CanvasID.new(id, parent_path).to_s
    end
end
