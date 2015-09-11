class GenericFilePresenter < CurationConcerns::GenericFilePresenter
  include CurationConcerns::Serializers
  delegate :viewing_hint, to: :solr_document

  def label
    nil
  end
end
