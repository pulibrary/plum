class StateValidator < ActiveModel::Validator
  delegate :validate, to: :inclusivity_validator

  private

    def inclusivity_validator
      @inclusivity_validator ||= ActiveModel::Validations::InclusionValidator.new(
        attributes: :state,
        in: valid_states,
        allow_blank: true
      )
    end

    def valid_states
      [
        "complete",
        "pending",
        "review"
      ]
    end
end
