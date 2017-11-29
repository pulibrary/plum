# frozen_string_literal: true
FactoryGirl.define do
  factory :ephemera_box do
    box_number [3]
    barcode ["32101091980639"]
    factory :ready_to_ship_box do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:ready_to_ship_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end
    factory :shipped_box do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:shipped_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end
    factory :received_box do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:received_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end
    factory :all_in_production_box do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:all_in_production_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end
  end
end
