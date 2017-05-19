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

  def apply_first_and_last
    source = list_source
    list_source.save
    return if resource.get_values(:head, cast: false) == source.head_id && resource.get_values(:tail, cast: false) == source.tail_id
    head_will_change!
    tail_will_change!
    resource.set_value(:head, source.head_id)
    resource.set_value(:tail, source.tail_id)
    save!
  end
end
