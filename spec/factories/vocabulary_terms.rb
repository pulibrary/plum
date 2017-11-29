# frozen_string_literal: true
FactoryGirl.define do
  factory :vocabulary_term do
    sequence(:label) { |n| "Literacy #{n}" }
    uri "http://id.loc.gov/authorities/subjects/sh85077482"
    code ""
    tgm_label ""
    lcsh_label ""
    vocabulary FactoryGirl.create(:vocabulary)
  end
end
