class RasterWorkShowPresenter < GeoConcerns::GeoConcernsShowPresenter
  include PlumAttributes

  self.work_presenter_class = ::VectorWorkShowPresenter
  self.file_format_service = GeoConcerns::RasterFormatService
end
