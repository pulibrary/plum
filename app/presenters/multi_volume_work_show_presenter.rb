class MultiVolumeWorkShowPresenter < CurationConcernsShowPresenter
  def file_presenter_class
    ::ScannedResourceShowPresenter
  end

  def viewing_hint
    'multi-part'
  end
end
