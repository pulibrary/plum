module CurationConcerns
  class VectorWorkForm < ::CurationConcerns::CurationConcernsForm
    include ::GeoConcerns::BasicGeoMetadataForm
    include ::GeoConcerns::ExternalMetadataFileForm
    include ::GeoConcerns::GeoreferencedForm
    self.model_class = ::VectorWork
  end
end
