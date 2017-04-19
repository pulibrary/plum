module Hyrax
  class ImageWorkForm < ::Hyrax::GeoWorkForm
    include ::GeoWorks::BasicGeoMetadataForm
    include ::GeoWorks::ExternalMetadataFileForm
    self.model_class = ::ImageWork
    self.terms += [:viewing_direction, :viewing_hint, :alternative, :edition, :cartographic_scale]
    self.required_fields = [:title, :source_metadata_identifier, :rights_statement, :coverage]

    def secondary_terms
      super + [:cartographic_scale, :alternative, :edition]
    end
  end
end
