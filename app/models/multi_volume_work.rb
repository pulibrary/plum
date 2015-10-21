# A work which has metadata and may have one or more ScannedResources members.
class MultiVolumeWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::CommonMetadata
  include ::NoidBehaviors

  ordered_aggregation :scanned_resources, has_member_relation: Hydra::PCDM::Vocab::PCDMTerms.hasMember, through: :list_source
end
