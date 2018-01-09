# frozen_string_literal: true
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
