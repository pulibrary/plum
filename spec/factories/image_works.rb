FactoryGirl.define do
  factory :image_work do
    title ["Test title"]
    rights_statement ["http://rightsstatements.org/vocab/NKC/1.0/"]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    state Vocab::FedoraResourceStatus.active

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :complete_image_work do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :pending_image_work do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:pending_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end
  end
end
