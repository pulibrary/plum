# Generated via
#  `rails generate hyrax:work MapSet`
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create a MapSet' do
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
      visit new_curation_concerns_map_set_path
      fill_in 'Title', with: 'Test MapSet'
      click_button 'Create MapSet'
      expect(page).to have_content 'Test MapSet'
    end
  end
end
