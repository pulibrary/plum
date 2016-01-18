FactoryGirl.define do
  factory :multi_volume_work do
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

    factory :multi_volume_work_with_volume do
      after(:build) do |work, evaluator|
        resource = FactoryGirl.build(:scanned_resource, user: evaluator.user)
        work.ordered_members << resource
      end
    end

    # https://github.com/projecthydra/hydra-head/blob/master/hydra-access-controls/app/models/concerns/hydra/access_controls/access_right.rb
    factory :campus_only_multi_volume_work do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end
  end
end
