FactoryGirl.define do
  factory :workflow_state, class: Sipity::WorkflowState do
    workflow
    name 'complete'
  end
end
