class ImageWorkShowPresenter < GeoConcerns::GeoConcernsShowPresenter
  include PlumAttributes

  self.work_presenter_class = ::RasterWorkShowPresenter
  self.file_format_service = GeoConcerns::ImageFormatService
end
