# frozen_string_literal: true
class LogicalOrderBase < ActiveFedora::Base
  property :label, predicate: ::RDF::Vocab::RDFS.label
  property :nodes, predicate: ::RDF::Vocab::DC.hasPart
  property :head, predicate: ::RDF::Vocab::IANA['first'], multiple: false, cast: false
  property :tail, predicate: ::RDF::Vocab::IANA.last, multiple: false, cast: false

  def order=(order)
    nodes_will_change!
    head_will_change!
    tail_will_change!
    label_will_change!
    order = LogicalOrder.new(order, ::RDF::URI(rdf_subject))
    graph = order.to_graph
    # Delete old statements
    subj = resource.subjects.to_a.select { |x| x.to_s.split("/").last.to_s.include?("#g") }
    subj.each do |s|
      resource.delete [s, nil, nil]
    end
    self.head = nil
    self.tail = nil
    self.label = nil
    resource << graph
    # Set nodes so that hash URIs get persisted to Fedora.
    self.nodes = graph.subjects.select { |x| x != rdf_subject }
    @order = nil
    @logical_order = nil
    order
  end

  def order
    @order ||= LogicalOrderGraph.new(resource, rdf_subject).to_h
  end

  def head
    resource.get_values(:head, cast: false)
  end

  def tail
    resource.get_values(:head, cast: false)
  end

  def object
    @logical_order ||= LogicalOrder.new(order)
  end

  # Not useful and slows down indexing.
  def create_date
    nil
  end

  # Not useful, slows down indexing.
  def modified_date
    nil
  end
end
