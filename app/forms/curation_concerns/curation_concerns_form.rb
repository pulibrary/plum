module CurationConcerns
  class CurationConcernsForm < CurationConcerns::Forms::WorkForm
    self.terms += [:access_policy, :rights_statement, :rights_note, :source_metadata_identifier, :portion_note, :description, :state, :workflow_note, :collection_ids]

    def notable_rights_statement?
      RightsStatementService.notable?(model.rights_statement)
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
  end
end
