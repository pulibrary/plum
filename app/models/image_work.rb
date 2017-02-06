class ImageWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoConcerns::ImageWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::GeoConcerns::BasicGeoMetadata
  include ::GeoMetadata
  include ::StateBehavior
  self.valid_child_concerns = [RasterWork]

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
