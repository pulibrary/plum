# frozen_string_literal: true
FactoryGirl.define do
  factory :sipity_entity, aliases: [:complete_sipity_entity], class: Sipity::Entity do
    proxy_for_global_id 'gid://internal/Mock/1'
    workflow { workflow_state.workflow }
    workflow_state

    factory :pending_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'pending'
    end

    factory :needs_qa_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'needs_qa'
    end

    factory :ready_to_ship_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'ready_to_ship'
    end

    factory :shipped_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'shipped'
    end

    factory :received_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'received'
    end

    factory :all_in_production_sipity_entity, class: Sipity::Entity do
      association :workflow_state, factory: :workflow_state, name: 'all_in_production'
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
