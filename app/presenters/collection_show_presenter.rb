class CollectionShowPresenter < CurationConcerns::CollectionPresenter
  include CurationConcerns::Serializers
  delegate :id, :title, :exhibit_id, to: :solr_document
end
