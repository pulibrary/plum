class FileSetPresenter < CurationConcerns::FileSetPresenter
  include CurationConcerns::Serializers
  delegate :viewing_hint, :title, :file_label, :width, :height, to: :solr_document

  def label
    nil
  end

  def thumbnail_id
    id
  end
end
