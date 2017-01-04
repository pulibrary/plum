class VectorWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::GeoConcerns::VectorWorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::GeoConcerns::BasicGeoMetadata
  include ::GeoConcerns::GeoreferencedBehavior
  include ::GeoMetadata
  include ::StateBehavior
  self.valid_child_concerns = []

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
