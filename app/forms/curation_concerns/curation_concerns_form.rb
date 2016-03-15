module CurationConcerns
  class CurationConcernsForm < CurationConcerns::Forms::WorkForm
    self.terms += [:holding_location, :rights_statement, :rights_note, :source_metadata_identifier, :portion_note, :description, :state, :workflow_note, :collection_ids, :ocr_language, :nav_date]
    delegate :collection_ids, to: :model

    def notable_rights_statement?
      RightsStatementService.notable?(rights_statement)
    end

    def self.multiple?(field)
      if field.to_sym == :description
        false
      else
        super
      end
    end

    def initialize_field(key)
      return if key.to_sym == :description
      super
    end

    def rights_statement
      if self["rights_statement"].blank?
        "http://rightsstatements.org/vocab/NKC/1.0/"
      else
        self["rights_statement"]
      end
    end
  end
end
