class ImageWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoWorks::ImageWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::GeoWorks::BasicGeoMetadata
  include ::GeoMetadata
  include ::StateBehavior
  self.valid_child_concerns = [RasterWork]

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
