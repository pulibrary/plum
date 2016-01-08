class ScannedResourcePDF
  class OutlineApplier
    attr_reader :order
    def initialize(order)
      @order = order
    end

    def apply(prawn_document)
      apply_nodes(prawn_document, order.nodes)
    end

    private

      def apply_nodes(prawn_document, nodes)
        nodes.each_with_index do |sub_node, _index|
          if !sub_node.proxy_for
            apply_section(prawn_document, sub_node)
          else
            if sub_node.proxy_for_object
              prawn_document.outline.page title: sub_node.proxy_for_object.to_s, destination: flattened_order.index(sub_node.proxy_for_object.id) + 1
            end
          end
        end
      end

      def apply_section(prawn_document, node)
        target_node = node.each_node.first
        if target_node
          destination = flattened_order.index(target_node.id) + 1
        else
          destination = nil
        end
        prawn_document.outline.section(node.label, destination: destination) do
          apply_nodes(prawn_document, node.nodes)
        end
      end

      def flattened_order
        @flattened_order ||= order.each_node.map(&:id)
      end
  end
end
