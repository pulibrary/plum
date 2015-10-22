require 'rails_helper'

RSpec.feature 'Home Page', type: :feature do
  describe 'a logged in user' do
    let(:user) { FactoryGirl.create(:curation_concern_creator) }

    before(:each) do
      sign_in user
    end

    scenario 'Logged in users see welcome text and links to create content' do
      visit root_path
      expect(page).to have_content('Plum: A Repository is a secure repository service')
      expect(page).to have_selector('li.work-type/h3.title', text: 'Scanned Resource')
    end
  end

  describe 'an anonymous user' do
    scenario 'Anonymous users see only welcome text' do
      visit root_path
      expect(page).to have_content('Plum: A Repository is a secure repository service')
      expect(page).not_to have_selector('li.work-type/h3.title', text: 'Scanned Resource')
    end
  end
end
