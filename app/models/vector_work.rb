class VectorWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoWorks::VectorWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::GeoWorks::BasicGeoMetadata
  include ::GeoWorks::GeoreferencedBehavior
  include ::GeoMetadata
  include ::StateBehavior
  self.valid_child_concerns = []

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
