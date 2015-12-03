##
# Object responsible for iterating over a params representation of a logical
# order.
class LogicalOrder
  attr_reader :order_hash, :node_class
  attr_accessor :rdf_subject
  # @param [Hash] order_hash The params representation of the order.
  # @param [RDF::URI] rdf_subject The subject of the head node
  # @param [#new] node_class The factory to generate child nodes.
  # @example
  #   LogicalOrder.new({"nodes": [ { "proxy": "a" } ]},
  #     RDF::URI("http://test.com"), LogicalOrder)
  def initialize(order_hash = {}, rdf_subject = nil, node_class = LogicalOrder)
    @order_hash = order_hash.with_indifferent_access
    @rdf_subject = RDF::URI(rdf_subject.to_s) if rdf_subject
    @node_class = node_class
  end

  # @return [Array<node_class>] Child nodes of this resource.
  def nodes
    @nodes ||= order_hash.fetch("nodes", []).map do |values|
      node_class.new(values)
    end
  end

  # @return [String] Label of the top level node.
  def label
    order_hash.fetch("label", nil)
  end

  # @return [::RDF::Graph] Ordered graph representation of the given ordered
  #   hash.
  def to_graph
    self_graph = ordered_list.to_graph
    self_graph << [rdf_subject, RDF::Vocab::RDFS.label, label] if label
    nodes.each do |node|
      self_graph << node.to_graph
    end
    if nodes.length > 0
      self_graph << [rdf_subject, RDF::Vocab::IANA.first, nodes.first.rdf_subject]
      self_graph << [rdf_subject, RDF::Vocab::IANA.last, nodes.last.rdf_subject]
    end
    self_graph
  end

  # @return [String] ID of this node.
  def id
    rdf_subject.to_s if rdf_subject.to_s.start_with?("#")
  end

  # @return [RDF::URI] URI of the resource this node is a proxy for.
  def proxy_for
    ActiveFedora::Base.id_to_uri(order_hash["proxy"]) if proxy_for_id
  end

  # @return [String] ID of the resource this node is a proxy for.
  def proxy_for_id
    order_hash["proxy"]
  end

  # @return [::RDF::URI] URI of this node.
  def rdf_subject
    @rdf_subject ||= ordered_list.send(:new_node_subject)
  end

  private

    def ordered_list
      @ordered_list ||=
        begin
          o = ActiveFedora::Orders::OrderedList.new(::RDF::Graph.new, nil, nil)
          nodes.each do |node|
            o.insert_proxy_for_at(o.length, node.proxy_for)
            node.rdf_subject = o.last.rdf_subject
          end
          o
        end
    end
end
