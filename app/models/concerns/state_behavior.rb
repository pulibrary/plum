module StateBehavior
  extend ActiveSupport::Concern

  included do
    # Sipity workflow state name
    def workflow_state
      to_sipity_entity.workflow_state.name
    rescue RuntimeError
      nil
    end
  end
end
