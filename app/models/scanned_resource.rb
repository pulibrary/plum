# Generated via
#  `rails generate curation_concerns:work ScannedResource`
class ScannedResource < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::CommonMetadata
  include ::NoidBehaviors
  include ::StructuralMetadata
  include ::HasPendingUploads
  include ::CollectionIndexing
  self.valid_child_concerns = []

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora.index_field_mapper.solr_name("ordered_by", :symbol)] ||= []
      doc[ActiveFedora.index_field_mapper.solr_name("ordered_by", :symbol)] += send(:ordered_by_ids)
    end
  end

  def serializable_hash(*_args)
    { id: id }
  end
end
