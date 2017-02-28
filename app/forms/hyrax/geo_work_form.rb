module Hyrax
  class GeoWorkForm < Hyrax::HyraxForm
    include ::GeoWorks::BasicGeoMetadataForm
    include ::GeoWorks::ExternalMetadataFileForm
    include ::GeoWorks::GeoreferencedForm
    self.terms += [:spatial, :temporal, :coverage, :issued, :should_populate_metadata, :cartographic_projection]
    self.required_fields = [:title, :rights_statement, :coverage]

    def primary_terms
      super - [:holding_location, :pdf_type, :nav_date, :portion_note, :related_url]
    end

    def secondary_terms
      super + [:spatial, :temporal, :issued, :cartographic_projection, :should_populate_metadata]
    end
  end
end
