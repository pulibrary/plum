module CurationConcerns
  class ImageWorkForm < ::CurationConcerns::CurationConcernsForm
    include ::GeoConcerns::BasicGeoMetadataForm
    include ::GeoConcerns::ExternalMetadataFileForm
    self.model_class = ::ImageWork
  end
end
