class MultiVolumeWorkShowPresenter < CurationConcernsShowPresenter
  def file_presenter_class
    ::ScannedResourceShowPresenter
  end
end
