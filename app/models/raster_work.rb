class RasterWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoWorks::RasterWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::GeoWorks::BasicGeoMetadata
  include ::GeoWorks::GeoreferencedBehavior
  include ::GeoMetadata
  include ::StateBehavior
  self.valid_child_concerns = [VectorWork]

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
