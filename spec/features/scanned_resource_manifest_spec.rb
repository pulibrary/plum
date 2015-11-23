require 'rails_helper'

RSpec.feature "ScannedResourcesController", type: :feature do
  let(:user) { FactoryGirl.create(:curation_concern_creator) }
  let(:open_resource) { FactoryGirl.create(:open_scanned_resource, user: user) }
  let(:private_resource) { FactoryGirl.create(:private_scanned_resource, user: user) }

  context "an anonymous user" do
    scenario "views a public manifest" do
      visit curation_concerns_scanned_resource_manifest_path open_resource
      expect(page.status_code).to eq 200
      expect(page).to have_content "http://plum.com/concern/scanned_resources/#{open_resource.id}/manifest"
      expect(page).to have_content "http://www.example.com/users/auth/cas"
      expect(page).not_to have_content "http://www.example.com/sign_out"
    end

    scenario "views a private manifest" do
      visit curation_concerns_scanned_resource_manifest_path private_resource
      expect(page.status_code).to eq 401
      expect(page).to have_content "http://www.example.com/users/auth/cas"
      expect(page).not_to have_content "http://www.example.com/sign_out"
    end
  end

  context "an authenticated user" do
    before(:each) do
      sign_in user
    end

    scenario "views a public manifest" do
      visit curation_concerns_scanned_resource_manifest_path open_resource
      expect(page.status_code).to eq 200
      expect(page).to have_content "http://plum.com/concern/scanned_resources/#{open_resource.id}/manifest"
      expect(page).to have_content "http://www.example.com/users/auth/cas"
      expect(page).to have_content "http://www.example.com/sign_out"
    end

    scenario "views a private manifest" do
      visit curation_concerns_scanned_resource_manifest_path private_resource
      expect(page.status_code).to eq 200
      expect(page).to have_content "http://plum.com/concern/scanned_resources/#{private_resource.id}/manifest"
      expect(page).to have_content "http://www.example.com/users/auth/cas"
      expect(page).to have_content "http://www.example.com/sign_out"
    end
  end
end
