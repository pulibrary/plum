FactoryGirl.define do
  factory :vocabulary_term do
    label "Literacy"
    uri "http://id.loc.gov/authorities/subjects/sh85077482"
    code ""
    tgm_label ""
    lcsh_label ""
    vocabulary FactoryGirl.create(:vocabulary)
    vocabulary_collection FactoryGirl.create(:vocabulary_collection)
  end
end
