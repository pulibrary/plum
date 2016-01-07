class ScannedResourcePDF
  class OutlineApplier
    attr_reader :order
    def initialize(order)
      @order = order
    end

    def apply(prawn_document)
      apply_nodes(prawn_document, order.nodes, 1)
    end

    private

      def apply_nodes(prawn_document, nodes, start)
        nodes.each_with_index do |sub_node, index|
          if !sub_node.proxy_for
            apply_section(prawn_document, sub_node, start + index)
          else
            prawn_document.outline.page title: sub_node.proxy_for_object.to_s, destination: start + index
          end
        end
      end

      def apply_section(prawn_document, node, start)
        if node.nodes.length > 0
          destination = start
        else
          destination = nil
        end
        prawn_document.outline.section(node.label, destination: destination) do
          apply_nodes(prawn_document, node.nodes, start)
        end
      end
  end
end
