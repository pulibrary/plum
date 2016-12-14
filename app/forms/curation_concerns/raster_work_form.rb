module CurationConcerns
  class RasterWorkForm < ::CurationConcerns::CurationConcernsForm
    include ::GeoConcerns::BasicGeoMetadataForm
    include ::GeoConcerns::ExternalMetadataFileForm
    include ::GeoConcerns::GeoreferencedForm
    self.model_class = ::RasterWork
  end
end
