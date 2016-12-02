FactoryGirl.define do
  factory :vector_work do
    title ["Test title"]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end
  end
end
