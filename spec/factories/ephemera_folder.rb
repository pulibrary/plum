FactoryGirl.define do
  factory :ephemera_folder do
    title ["Example Folder"]
    folder_number [3]
    barcode ["32101091980639"]
    rights_statement ["http://rightsstatements.org/vocab/NKC/1.0/"]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :complete_ephemera_folder do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:complete_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end

    factory :needs_qa_ephemera_folder do
      after(:create) do |work, evaluator|
        FactoryGirl.create(:needs_qa_sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
        work.save
      end
    end
  end
end
