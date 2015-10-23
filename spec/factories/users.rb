require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "username#{n}" }
    sequence(:email) { |n| "email-#{srand}@test.com" }
    provider 'cas'
    uid do |user|
      user.username
    end
    factory :admin do
      roles { [Role.where(name: 'admin').first_or_create] }
    end

    factory :campus_patron do
      # All CAS users are campus patrons.
    end

    factory :curation_concern_creator do
      roles { [Role.where(name: 'curation_concern_creator').first_or_create] }
    end
  end
end
