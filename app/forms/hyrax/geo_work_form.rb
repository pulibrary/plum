module Hyrax
  class GeoWorkForm < Hyrax::HyraxForm
    include ::GeoWorks::BasicGeoMetadataForm
    include ::GeoWorks::ExternalMetadataFileForm
    include ::GeoWorks::GeoreferencedForm
    self.terms += [:spatial, :temporal, :coverage, :issued, :should_populate_metadata, :cartographic_projection]
    self.required_fields = [:title, :rights_statement, :coverage]

    def primary_terms
      terms = super + [:description, :should_populate_metadata]
      terms - [:holding_location, :pdf_type, :nav_date, :portion_note, :related_url]
    end

    def secondary_terms
      super + [
        :subject,
        :keyword,
        :spatial,
        :temporal,
        :date_created,
        :issued,
        :creator,
        :contributor,
        :publisher,
        :language,
        :cartographic_projection
      ]
    end

    def multiple?(field)
      return false if ['rights_statement'].include?(field.to_s)
      super
    end
  end
end
