class VectorWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::GeoConcerns::VectorWorkBehavior
  include ::Hyrax::BasicMetadata
  include ::GeoConcerns::BasicGeoMetadata
  include ::GeoConcerns::GeoreferencedBehavior
  include ::GeoMetadata
  include ::StateBehavior
  self.valid_child_concerns = []

  # Use local indexer
  self.indexer = GeoWorkIndexer
end
