# frozen_string_literal: true
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

    def self.multiple?(field)
      # Necessary to permit coverage param. Coverage is declared as
      # single-valued in GeoWorks. We'll keep it that way for now.
      return false if field.to_sym == :coverage
      super
    end
  end
end
