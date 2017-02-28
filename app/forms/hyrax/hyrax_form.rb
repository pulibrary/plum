module Hyrax
  class HyraxForm < Hyrax::Forms::WorkForm
    self.terms += [:holding_location, :rights_statement, :rights_note, :source_metadata_identifier, :portion_note, :description, :state, :collection_ids, :ocr_language, :nav_date, :pdf_type, :start_canvas, :uploaded_files]
    self.required_fields = [:title, :source_metadata_identifier, :rights_statement]
    delegate :collection_ids, to: :model

    def notable_rights_statement?
      RightsStatementService.new.notable?(rights_statement)
    end

    def self.multiple?(field)
      if field.to_sym == :description
        false
      elsif field.to_sym == :pdf_type
        false
      elsif field.to_sym == :rights_statement
        false
      elsif field.to_sym == :identifier
        false
      else
        super
      end
    end

    # @param [ActiveSupport::Parameters]
    # @return [Hash] a hash suitable for populating Collection attributes.
    def self.model_attributes(_)
      attrs = super
      # cast pdf_type back to multivalued
      attrs[:pdf_type] = Array(attrs[:pdf_type]) if attrs[:pdf_type]
      attrs
    end

    def initialize_field(key)
      return if [:description, :pdf_type].include?(key.to_sym)
      super
    end

    def description
      Array.wrap(super).first
    end

    def pdf_type
      if self["pdf_type"].blank?
        "gray"
      else
        self["pdf_type"]
      end
    end

    def rights_statement
      if Array(self["rights_statement"]).first.blank?
        "http://rightsstatements.org/vocab/NKC/1.0/"
      else
        self["rights_statement"]
      end
    end

    def primary_terms
      super + [:rights_note, :holding_location, :pdf_type, :portion_note, :description, :nav_date]
    end

    def secondary_terms
      []
    end
  end
end
