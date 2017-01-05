FactoryGirl.define do
  factory :scanned_resource do
    title ["Test title"]
    source_metadata_identifier "1234567"
    rights_statement "http://rightsstatements.org/vocab/NKC/1.0/"
    description "900 years of time and space, and I’ve never been slapped by someone’s mother."
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    state Vocab::FedoraResourceStatus.active
    pdf_type ["gray"]

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :complete_scanned_resource, aliases: [:complete_open_scanned_resource] do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :pending_scanned_resource do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:pending_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :flagged_scanned_resource do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:flagged_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :metadata_review_scanned_resource do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:metadata_review_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :final_review_scanned_resource do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:final_review_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :takedown_scanned_resource do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:takedown_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    # https://github.com/projecthydra/hydra-head/blob/master/hydra-access-controls/app/models/concerns/hydra/access_controls/access_right.rb
    factory :campus_only_scanned_resource do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED

      factory :complete_campus_only_scanned_resource do
        after(:create) do |work, evaluator|
          FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
          work.save
        end
      end
    end

    factory :private_scanned_resource do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

      factory :complete_private_scanned_resource do
        after(:create) do |work, evaluator|
          FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
          work.save
        end
      end
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

    factory :complete_scanned_resource_with_multi_volume_work do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        parent = FactoryGirl.create(:complete_multi_volume_work, user: evaluator.user)
        parent.ordered_members << work
        parent.save
        work.save
      end
    end

    factory :metadata_review_scanned_resource_with_multi_volume_work do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:metadata_review_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        parent = FactoryGirl.create(:complete_multi_volume_work, user: evaluator.user)
        parent.ordered_members << work
        parent.save
        work.save
      end
    end

    factory :scanned_resource_in_collection do
      after(:create) do |scanned_resource, evaluator|
        scanned_resource.member_of_collections = [FactoryGirl.create(:collection, user: evaluator.user)]
        scanned_resource.save
      end

      factory :complete_scanned_resource_in_collection do
        after(:create) do |work, evaluator|
          FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
          work.save
        end
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
