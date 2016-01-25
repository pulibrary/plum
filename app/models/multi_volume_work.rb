# A work which has metadata and may have one or more ScannedResources members.
class MultiVolumeWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::CommonMetadata
  include ::NoidBehaviors
  include ::StructuralMetadata
  include ::HasPendingUploads

  def to_solr(solr_doc = {})
    super.tap do |doc|
      in_collections.each do |col|
        doc[ActiveFedora::SolrQueryBuilder.solr_name("collection", :facetable)] = col.title
        doc[ActiveFedora::SolrQueryBuilder.solr_name("collection_slug", :facetable)] = col.exhibit_id
      end
    end
  end
end
