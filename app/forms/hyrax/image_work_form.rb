module Hyrax
  class ImageWorkForm < ::Hyrax::GeoWorkForm
    include ::GeoWorks::BasicGeoMetadataForm
    include ::GeoWorks::ExternalMetadataFileForm
    self.model_class = ::ImageWork

    def secondary_terms
      super - [:cartographic_projection]
    end
  end
end
