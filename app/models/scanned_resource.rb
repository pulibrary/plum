# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work ScannedResource`
class ScannedResource < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include ::CommonMetadata
  include ::ApplyRemoteMetadata
  include ::StateBehavior
  include ::StructuralMetadata
  include ::HasPendingUploads
  include ::CollectionIndexing
  include ::ApplyFirstAndLast
  include ::DefaultReadGroups
  self.valid_child_concerns = []

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora.index_field_mapper.solr_name("ordered_by", :symbol)] ||= []
      doc[ActiveFedora.index_field_mapper.solr_name("ordered_by", :symbol)] += send(:ordered_by_ids)
    end
  end
end
