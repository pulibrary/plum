# frozen_string_literal: true
class RasterWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoWorks::RasterWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::CommonMetadata
  include ::StateBehavior
  include ::GeoWorks::BasicGeoMetadata
  include ::GeoWorks::GeoreferencedBehavior
  include ::DefaultReadGroups
  self.valid_child_concerns = [VectorWork]

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
