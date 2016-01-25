class RightsStatementValidator < ActiveModel::Validator
  delegate :validate, to: :inclusivity_validator

  private

    def inclusivity_validator
      @inclusivity_validator ||= ActiveModel::Validations::InclusionValidator.new(
        attributes: :rights_statement,
        in: valid_rights_statements,
        allow_blank: false
      )
    end

    def valid_rights_statements
      RightsStatementService.valid_statements
    end
end
