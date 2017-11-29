# frozen_string_literal: true
##
# Primarily responsible for going from an ordered graph to a params
#   representation of an order.
class LogicalOrderGraph
  attr_reader :graph, :head_subject
  # @param [::RDF::Enumerable] graph Graph to parse.
  # @param [::RDF::URI] head_subject The subject of the top node in the ordered
  #   list.
  def initialize(graph, head_subject)
    @graph = graph
    @head_subject = head_subject
  end

  # @return [Hash] The params representation of an order.
  def to_h
    hsh = {}
    hsh["label"] = label if label.present? && label.to_s != head_subject.to_s
    hsh["nodes"] = nodes.map(&:to_h) unless nodes.empty?
    hsh["proxy"] = proxy_for_id if proxy_for_id
    hsh.with_indifferent_access
  end

  # @return [Array<LogicalOrderGraph>] Child nodes of this resource.
  def nodes
    ordered_list.map do |x|
      LogicalOrderGraph.new(graph, x.rdf_subject)
    end
  end

  # @return [String] Label of the top level node.
  def label
    node.rdf_label.first
  end

  # @return [String] ID of the resource this node is a proxy for.
  def proxy_for_id
    ActiveFedora::Base.uri_to_id(node.proxy_for.first) if node.proxy_for.first
  end

  private

    def node
      @node ||= Node.new(head_subject, data: graph)
    end

    def ordered_list
      @ordered_list ||= ActiveFedora::Orders::OrderedList.new(graph, node.first_ordered.first, node.last_ordered.first)
    end

    class Node < ActiveTriples::Resource
      property :prev, predicate: ::RDF::Vocab::IANA.prev, cast: false
      property :next, predicate: ::RDF::Vocab::IANA.next, cast: false
      property :first_ordered, predicate: ::RDF::Vocab::IANA.first, cast: false
      property :last_ordered, predicate: ::RDF::Vocab::IANA.last, cast: false
      property :proxy_for, predicate: ::RDF::Vocab::ORE.proxyFor, cast: false
    end
end
