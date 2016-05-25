class MVWThumbnailPathService < CurationConcerns::ThumbnailPathService
  class << self
    def call(object)
      return default_image unless object.thumbnail_id
      return call(object.thumbnail) unless object.thumbnail.is_a?(FileSet)
      super
    end
  end
end
