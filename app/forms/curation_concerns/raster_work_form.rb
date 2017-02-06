module Hyrax
  class RasterWorkForm < ::Hyrax::HyraxForm
    include ::GeoConcerns::BasicGeoMetadataForm
    include ::GeoConcerns::ExternalMetadataFileForm
    include ::GeoConcerns::GeoreferencedForm
    self.model_class = ::RasterWork
  end
end
