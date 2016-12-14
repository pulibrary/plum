class RasterWorkShowPresenter < GeoConcernsShowPresenter
  self.work_presenter_class = ::VectorWorkShowPresenter
  self.file_format_service = GeoConcerns::RasterFormatService
end
