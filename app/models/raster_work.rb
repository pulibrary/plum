class RasterWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoConcerns::RasterWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::GeoConcerns::BasicGeoMetadata
  include ::GeoConcerns::GeoreferencedBehavior
  include ::GeoMetadata
  include ::StateBehavior
  self.valid_child_concerns = [VectorWork]

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
