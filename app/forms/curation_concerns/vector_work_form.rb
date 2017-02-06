module Hyrax
  class VectorWorkForm < ::Hyrax::HyraxForm
    include ::GeoConcerns::BasicGeoMetadataForm
    include ::GeoConcerns::ExternalMetadataFileForm
    include ::GeoConcerns::GeoreferencedForm
    self.model_class = ::VectorWork
  end
end
