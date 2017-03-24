class ImageWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoWorks::ImageWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::CommonMetadata
  include ::StateBehavior
  include ::StructuralMetadata
  include ::ApplyRemoteMetadata
  include ::GeoWorks::BasicGeoMetadata
  self.valid_child_concerns = [RasterWork]

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
