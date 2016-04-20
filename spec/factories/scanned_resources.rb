FactoryGirl.define do
  factory :scanned_resource do
    title ["Test title"]
    source_metadata_identifier "1234567"
    rights_statement "http://rightsstatements.org/vocab/NKC/1.0/"
    description "900 years of time and space, and I’ve never been slapped by someone’s mother."
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    state "complete"

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    # https://github.com/projecthydra/hydra-head/blob/master/hydra-access-controls/app/models/concerns/hydra/access_controls/access_right.rb
    factory :campus_only_scanned_resource do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end

    factory :private_scanned_resource do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    factory :open_scanned_resource do
    end

    factory :scanned_resource_with_multi_volume_work do
      after(:create) do |work, evaluator|
        parent = FactoryGirl.create(:multi_volume_work, user: evaluator.user)
        parent.ordered_members << work
        parent.save
        work.save
      end
    end

    factory :scanned_resource_in_collection do
      after(:create) do |scanned_resource, evaluator|
        col = FactoryGirl.create(:collection, user: evaluator.user)
        col.members << scanned_resource
        col.save
        col.update_index
      end
    end

    factory :scanned_resource_with_file do
      after(:create) do |scanned_resource, evaluator|
        file = FactoryGirl.create(:file_set, user: evaluator.user)
        scanned_resource.ordered_members << file
        scanned_resource.save
        file.update_index
      end
    end
  end
end
