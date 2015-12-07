class FileSetPresenter < CurationConcerns::FileSetPresenter
  include CurationConcerns::Serializers
  delegate :viewing_hint, :title, to: :solr_document

  def label
    nil
  end
end
