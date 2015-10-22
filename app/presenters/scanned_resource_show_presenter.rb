class ScannedResourceShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, to: :solr_document

  def file_presenter_class
    ::FileSetPresenter
  end

  def file_set_ids
    ordered_ids
  end
end
