module Hyrax
  class GeoWorkForm < Hyrax::Forms::WorkForm
    include ::GeoWorks::BasicGeoMetadataForm
    include ::GeoWorks::ExternalMetadataFileForm
    include ::GeoWorks::GeoreferencedForm
    self.terms += [:rights_statement, :rights_note]
    self.required_fields = [:title, :rights_statement, :coverage]

    def notable_rights_statement?
      RightsStatementService.new.notable?(rights_statement)
    end

    def self.multiple?(field)
      if field.to_sym == :description
        false
      elsif field.to_sym == :rights_statement
        false
      elsif field.to_sym == :identifier
        false
      else
        super
      end
    end

    def description
      Array.wrap(super).first
    end

    def initialize_field(key)
      return if [:description].include?(key.to_sym)
      super
    end

    def rights_statement
      if Array(self["rights_statement"]).first.blank?
        "http://rightsstatements.org/vocab/NKC/1.0/"
      else
        self["rights_statement"]
      end
    end

    def primary_terms
      super + [:rights_note]
    end

    def secondary_terms
      super - [:creator, :contributor, :keyword, :rights, :source]
    end
  end
end
