class FileSetPresenter < Hyrax::FileSetPresenter
  include Hyrax::Serializers
  delegate :viewing_hint, :title, :file_label, :width, :height, :digest, :date_modified,
           :well_formed, :valid, :color_space, :profile_name, :ocr_text, :date_uploaded, to: :solr_document

  def thumbnail_id
    id
  end

  def to_s
    if title.present?
      Array(title).join(' | ')
    elsif label.present?
      label
    else
      'No Title'
    end
  end
end
