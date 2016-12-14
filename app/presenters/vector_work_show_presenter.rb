class VectorWorkShowPresenter < GeoConcerns::GeoConcernsShowPresenter
  include PlumAttributes

  self.file_format_service = GeoConcerns::VectorFormatService
end
