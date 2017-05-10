module Hyrax
  class HyraxForm < ::Hyrax::Forms::WorkForm
    include SingleValuedForm
    self.terms += [:holding_location, :rights_statement, :rights_note, :source_metadata_identifier, :portion_note, :description, :abstract, :state, :member_of_collection_ids, :ocr_language, :nav_date, :pdf_type, :start_canvas, :uploaded_files, :local_identifier]
    self.required_fields = [:title, :source_metadata_identifier, :rights_statement]
    self.single_valued_fields = [:pdf_type, :rights_statement, :sort_title, :portion_note, :abstract, :replaces, :rights_note, :source_metadata_identifier, :source_metadata, :source_jsonld, :holding_location, :nav_date, :start_canvas, :cartographic_scale, :viewing_hint, :viewing_direction, :start_canvas]
    delegate :member_of_collection_ids, to: :model

    def notable_rights_statement?
      RightsStatementService.new.notable?(rights_statement)
    end

    def self.multiple?(field)
      return false if field.to_sym == :identifier
      super
    end

    def initialize_field(key)
      return if [:description].include?(key.to_sym)
      super
    end

    def pdf_type
      if self["pdf_type"].blank?
        "gray"
      else
        self["pdf_type"]
      end
    end

    def rights_statement
      if self[:rights_statement].present?
        self[:rights_statement]
      else
        "http://rightsstatements.org/vocab/NKC/1.0/"
      end
    end

    def primary_terms
      super + [:rights_note, :local_identifier, :holding_location, :pdf_type, :portion_note, :nav_date]
    end

    def secondary_terms
      []
    end
  end
end
