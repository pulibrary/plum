# A work which has metadata and may have one or more ScannedResources members.
class MultiVolumeWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::CommonMetadata
  include ::NoidBehaviors

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora::SolrQueryBuilder.solr_name("collection", :facetable)] = in_collections.collect(&:title)
    end
  end
end
