class FileSetPresenter < CurationConcerns::FileSetPresenter
  include CurationConcerns::Serializers
  delegate :viewing_hint, :title, :file_label, :width, :height, :digest, :date_modified,
           :well_formed, :valid, :color_space, :profile_name, to: :solr_document

  def thumbnail_id
    id
  end
end
