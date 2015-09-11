FactoryGirl.define do
  factory :scanned_book do
    title ["Test title"]
    source_metadata_identifier "1234567"
    access_policy "Do you want a jelly baby?"
    use_and_reproduction "Jamie, remind me to give you a lesson in tying knots, sometime."
    description "900 years of time and space, and I’ve never been slapped by someone’s mother."
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    # https://github.com/projecthydra/hydra-head/blob/master/hydra-access-controls/app/models/concerns/hydra/access_controls/access_right.rb
    factory :campus_only_scanned_book do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end
  end
end
