# Generated via
#  `rails generate curation_concerns:work ScannedResource`
class ScannedResource < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::CommonMetadata
  include ::NoidBehaviors
  include ::StructuralMetadata
  include ::HasPendingUploads

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora::SolrQueryBuilder.solr_name("ordered_by", :symbol)] ||= []
      doc[ActiveFedora::SolrQueryBuilder.solr_name("ordered_by", :symbol)] += send(:ordered_by_ids)
      in_collections.each do |col|
        doc[ActiveFedora::SolrQueryBuilder.solr_name("collection", :facetable)] = col.title
        doc[ActiveFedora::SolrQueryBuilder.solr_name("collection_slug", :facetable)] = col.exhibit_id
      end
    end
  end
end
