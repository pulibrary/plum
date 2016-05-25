# A work which has metadata and may have one or more ScannedResources members.
class MultiVolumeWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::CommonMetadata
  include ::NoidBehaviors
  include ::StructuralMetadata
  include ::HasPendingUploads
  include ::CollectionIndexing
  self.indexer = MultiVolumeWorkIndexer
end
