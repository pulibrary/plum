module Hyrax
  class VectorWorkForm < ::Hyrax::GeoWorkForm
    include ::GeoWorks::BasicGeoMetadataForm
    include ::GeoWorks::ExternalMetadataFileForm
    include ::GeoWorks::GeoreferencedForm
    self.model_class = ::VectorWork
  end
end
