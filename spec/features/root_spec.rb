# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Home Page', type: :feature do
  describe 'a logged in user' do
    let(:user) { FactoryGirl.create(:image_editor) }

    before do
      sign_in user
    end

    scenario 'Logged in users see welcome text and links to create content' do
      visit root_path
      expect(page).to have_content('Digital PUL')
      expect(page).to have_selector('li.work-type/h4.title', text: 'Scanned Resource')
      expect(page).to have_selector('li.work-type/h4.title', text: 'Collection')
    end
  end

  describe 'an anonymous user' do
    scenario 'Anonymous users see only welcome text' do
      visit root_path
      expect(page).to have_content('Digital PUL')
      expect(page).not_to have_selector('li.work-type/h4.title', text: 'Scanned Resource')
      expect(page).not_to have_selector('li.work-type/h4.title', text: 'Collection')
    end
  end
end
