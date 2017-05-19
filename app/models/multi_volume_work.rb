# A work which has metadata and may have one or more ScannedResources members.
class MultiVolumeWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include ::CommonMetadata
  include ::ApplyRemoteMetadata
  include ::StateBehavior
  include ::StructuralMetadata
  include ::HasPendingUploads
  include ::CollectionIndexing
  include ::ApplyFirstAndLast
  self.valid_child_concerns = [ScannedResource]

  def thumbnail_id
    return nil if thumbnail.nil?
    thumbnail.respond_to?(:thumbnail) ? thumbnail.thumbnail.try(:id) : thumbnail.try(:id)
  end

  before_destroy :cleanup_members

  def cleanup_members
    members.each do |member|
      logger.debug "Destroying member: #{member.id}"
      member.destroy
    end
  end
end
