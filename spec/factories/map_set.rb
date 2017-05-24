FactoryGirl.define do
  factory :map_set do
    title ["Test title"]
    source_metadata_identifier ["1234567"]
    rights_statement ["http://rightsstatements.org/vocab/NKC/1.0/"]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    state Vocab::FedoraResourceStatus.active

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :complete_map_set do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :pending_map_set do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:pending_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :map_set_with_image_work do
      after(:build) do |work, evaluator|
        resource = FactoryGirl.build(:image_work, user: evaluator.user)
        work.ordered_members << resource
        file = FactoryGirl.create(:file_set, user: evaluator.user, geo_mime_type: 'image/tiff')
        work.ordered_members << file
        work.save
        file.update_index
      end
    end

    factory :map_set_with_metadata_file do
      after(:build) do |work, evaluator|
        metadata_file = FactoryGirl.create(:file_set, user: evaluator.user, geo_mime_type: 'application/xml; schema=fgdc')
        work.ordered_members << metadata_file
        work.save
        metadata_file.update_index
      end
    end
  end
end
