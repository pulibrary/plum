class FileSetIndexer < CurationConcerns::FileSetIndexer
  self.thumbnail_path_service = ThumbnailPathService
end
