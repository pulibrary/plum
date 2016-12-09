class RasterWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::GeoConcerns::RasterWorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::GeoConcerns::BasicGeoMetadata
  include ::GeoConcerns::GeoreferencedBehavior
  self.valid_child_concerns = [VectorWork]

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
