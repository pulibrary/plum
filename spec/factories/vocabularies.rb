FactoryGirl.define do
  factory :vocabulary do
    sequence(:label) { |n| "LAE Subjects #{n}" }
  end
end
