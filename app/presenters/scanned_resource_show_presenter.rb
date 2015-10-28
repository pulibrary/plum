class ScannedResourceShowPresenter < CurationConcernsShowPresenter
  def file_presenter_class
    ::FileSetPresenter
  end

  def file_set_ids
    ordered_ids
  end
end
