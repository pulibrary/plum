FactoryGirl.define do
  factory :collection do
    title "Test Collection"
    exhibit_id "slug1"

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end
  end
end
