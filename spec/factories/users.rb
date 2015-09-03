require 'factory_girl'

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email-#{srand}@test.com" }
    password 'a password'
    password_confirmation 'a password'

    factory :admin do
      roles { [Role.where(name: 'admin').first_or_create] }
    end

    factory :campus_patron do
      roles { [Role.where(name: 'campus_patron').first_or_create] }
    end

    factory :scanned_book_creator do
      roles { [Role.where(name: 'scanned_book_creator').first_or_create] }
    end
  end
end
