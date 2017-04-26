class MapSet < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include ::CommonMetadata
  include ::StateBehavior
  include ::StructuralMetadata
  include ::ApplyRemoteMetadata
  include ::HasPendingUploads
  include ::CollectionIndexing
  include ::GeoWorks::BasicGeoMetadata
  include ::GeoWorks::GeoreferencedBehavior
  include ::GeoWorks::MetadataExtractionHelper
  self.valid_child_concerns = [ImageWork, ScannedResource]
end
