FactoryGirl.define do
  factory :vocabulary_collection do
    label "Education"
    vocabulary FactoryGirl.create(:vocabulary)
  end
end
