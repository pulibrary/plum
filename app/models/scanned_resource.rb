# Generated via
#  `rails generate hyrax:work ScannedResource`
class ScannedResource < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include ::CommonMetadata
  include ::ApplyRemoteMetadata
  include ::StateBehavior
  include ::StructuralMetadata
  include ::HasPendingUploads
  include ::CollectionIndexing
  self.valid_child_concerns = []

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc[ActiveFedora.index_field_mapper.solr_name("ordered_by", :symbol)] ||= []
      doc[ActiveFedora.index_field_mapper.solr_name("ordered_by", :symbol)] += send(:ordered_by_ids)
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
