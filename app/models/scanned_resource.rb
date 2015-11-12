# Generated via
#  `rails generate curation_concerns:work ScannedResource`
class ScannedResource < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::CommonMetadata
  include ::NoidBehaviors
  include ::GeneratesPdfs

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora::SolrQueryBuilder.solr_name("ordered_by", :symbol)] ||= []
      doc[ActiveFedora::SolrQueryBuilder.solr_name("ordered_by", :symbol)] += send(:ordered_by_ids)
    end
  end

  def pending_uploads
    PendingUpload.where(curation_concern_id: id)
  end
end
