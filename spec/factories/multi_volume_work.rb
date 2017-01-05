FactoryGirl.define do
  factory :multi_volume_work do
    title ["Test title"]
    source_metadata_identifier "1234567"
    rights_statement "http://rightsstatements.org/vocab/NKC/1.0/"
    description "900 years of time and space, and I’ve never been slapped by someone’s mother."
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    state Vocab::FedoraResourceStatus.active

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :complete_multi_volume_work, aliases: [:complete_open_multi_volume_work] do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :pending_multi_volume_work do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:pending_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :metadata_review_multi_volume_work do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:metadata_review_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :multi_volume_work_with_volume do
      after(:build) do |work, evaluator|
        resource = FactoryGirl.build(:scanned_resource, user: evaluator.user)
        work.ordered_members << resource
      end
    end

    factory :multi_volume_work_with_file do
      after(:create) do |scanned_resource, evaluator|
        file = FactoryGirl.create(:file_set, user: evaluator.user)
        scanned_resource.ordered_members << file
        scanned_resource.save
        file.update_index
      end
    end

    # https://github.com/projecthydra/hydra-head/blob/master/hydra-access-controls/app/models/concerns/hydra/access_controls/access_right.rb
    factory :campus_only_multi_volume_work do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end
  end
end
