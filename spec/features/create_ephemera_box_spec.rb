# Generated via
#  `rails generate hyrax:work EphemeraBox`
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a EphemeraBox' do
  context 'a logged in user' do
    let(:user_attributes) do
      { username: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end

    before do
      login_as user
    end

    scenario do
      visit new_curation_concerns_ephemera_box_path
      fill_in 'Title', with: 'Test EphemeraBox'
      click_button 'Create EphemeraBox'
      expect(page).to have_content 'Test EphemeraBox'
    end
  end
end
