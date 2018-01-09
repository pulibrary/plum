# frozen_string_literal: true
class VectorWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoWorks::VectorWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::CommonMetadata
  include ::StateBehavior
  include ::GeoWorks::BasicGeoMetadata
  include ::GeoWorks::GeoreferencedBehavior
  include ::DefaultReadGroups
  self.valid_child_concerns = []

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
