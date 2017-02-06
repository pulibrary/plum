class ScannedResourceShowPresenter < HyraxShowPresenter
  include PlumAttributes

  delegate :has?, :first, to: :solr_document
  self.file_presenter_class = ::FileSetPresenter
  self.work_presenter_class = ::MultiVolumeWorkShowPresenter.work_presenter_class
end
