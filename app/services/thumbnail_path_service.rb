class ThumbnailPathService < Hyrax::ThumbnailPathService
  class << self
    def thumbnail_filepath(thumb)
      PairtreeDerivativePath.derivative_path_for_reference(thumb, 'thumbnail')
    end
  end
end
