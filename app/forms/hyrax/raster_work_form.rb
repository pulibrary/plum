# frozen_string_literal: true
module Hyrax
  class RasterWorkForm < ::Hyrax::GeoWorkForm
    include ::GeoWorks::BasicGeoMetadataForm
    include ::GeoWorks::ExternalMetadataFileForm
    include ::GeoWorks::GeoreferencedForm
    self.model_class = ::RasterWork
  end
end
