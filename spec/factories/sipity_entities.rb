FactoryGirl.define do
  factory :sipity_entity, aliases: [:complete_sipity_entity], class: Sipity::Entity do
    proxy_for_global_id 'gid://internal/Mock/1'
    workflow { workflow_state.workflow }
    workflow_state

    factory :pending_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'pending'
    end

    factory :flagged_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'flagged'
    end

    factory :metadata_review_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'metadata_review'
    end

    factory :final_review_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'final_review'
    end

    factory :takedown_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'takedown'
    end
  end
end
