FactoryGirl.define do
  factory :ephemera_folder do
    title ["Example Folder"]
    folder_number [3]
    identifier ["32101091980639"]
    rights_statement ["http://rightsstatements.org/vocab/NKC/1.0/"]

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end
  end
end
