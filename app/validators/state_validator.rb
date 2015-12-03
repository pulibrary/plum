class StateValidator < ActiveModel::Validator
  def validate(record)
    inclusivity_validator.validate record
    validate_transition record
  end

  private

    def validate_transition(record)
      return unless record.state_changed? && !record.state_was.nil?
      return if StateWorkflow.new(record.state_was).aasm.states(permitted: true).include? record.state.to_sym
      record.errors.add :state, "Cannot transition from #{record.state_was} to #{record.state}"
    end

    def inclusivity_validator
      @inclusivity_validator ||= ActiveModel::Validations::InclusionValidator.new(
        attributes: :state,
        in: valid_states,
        allow_blank: true
      )
    end

    def valid_states
      [
        "pending",
        "metadata_review",
        "final_review",
        "complete",
        "flagged",
        "takedown"
      ]
    end
end
