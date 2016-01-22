module StructuralMetadata
  extend ActiveSupport::Concern

  included do
    contains :logical_order, class_name: "LogicalOrderBase"
  end

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora::SolrQueryBuilder.solr_name("logical_order", :symbol)] = [logical_order.order.to_json]
      doc[ActiveFedora::SolrQueryBuilder.solr_name("logical_order_headings", :stored_searchable)] = logical_order.object.each_section.map(&:label)
    end
  end
end
