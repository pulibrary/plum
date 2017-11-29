# frozen_string_literal: true
module Workflow
  module InitializeState
    def self.call(resource, workflow_name, state_name)
      workflow = Sipity::Workflow.where(name: workflow_name).first
      state = workflow.workflow_states.where(name: state_name).first
      Sipity::Entity.create!(proxy_for_global_id: resource.to_global_id, workflow_state: state, workflow: workflow)
    end
  end
end
