require 'rails_helper'

describe PurlController do
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_resource) { FactoryGirl.create(:scanned_resource, user: user, title: ['Dummy Title'], state: 'complete', source_metadata_identifier: 'BHR9405') }
  let(:multi_volume_work) { FactoryGirl.create(:multi_volume_work, user: user, title: ['Dummy Title'], state: 'complete', source_metadata_identifier: 'ABE9721') }
  let(:file_set) { FactoryGirl.create(:file_set, user: user, label: 'BHR9405-1-0001.tif', source_metadata_identifier: 'BHR9405-1-0001') }

  describe "default" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
      scanned_resource
      multi_volume_work
      file_set
    end
    context "with a matching id" do
      shared_examples "responses for matches" do
        before(:each) do
          get :default, id: id, format: format
        end
        context "in html" do
          let(:format) { 'html' }
          it "redirects to the scanned_resource page" do
            expect(response).to redirect_to target_path
          end
        end
        context "in json" do
          let(:format) { 'json' }
          it 'renders a json response' do
            expect(JSON.parse(response.body)['url']).to match target_path
          end
        end
      end
      context "for a ScannedResource" do
        let(:id) { scanned_resource.source_metadata_identifier }
        let(:target_path) { curation_concerns_scanned_resource_path(scanned_resource) }
        include_examples "responses for matches"
      end
      context "for a MultiVolumeWork" do
        let(:id) { multi_volume_work.source_metadata_identifier }
        let(:target_path) { curation_concerns_multi_volume_work_path(multi_volume_work) }
        include_examples "responses for matches"
      end
      context "for a FileSet" do
        let(:id) { file_set.source_metadata_identifier }
        let(:target_path) { curation_concerns_file_set_path(file_set) }
        include_examples "responses for matches"
      end
    end
    shared_examples "responses for no matches" do
      let(:target_path) { Plum.config['purl_redirect_url'] % id }
      before(:each) do
        get :default, id: id, format: format
      end
      context "in html" do
        let(:format) { 'html' }
        it "redirects to #{Plum.config['purl_redirect_url']}" do
          expect(response).to redirect_to target_path
        end
      end
      context "in json" do
        let(:format) { 'json' }
        it 'renders a json response' do
          expect(JSON.parse(response.body)['url']).to match target_path
        end
      end
    end
    context "with an invalid id" do
      let(:id) { 'BHR940' }
      before(:each) do
        scanned_resource
      end
      include_examples "responses for no matches"
    end
    context "with an unmatched id" do
      let!(:id) { scanned_resource.source_metadata_identifier }
      before(:each) do
        scanned_resource.destroy!
      end
      include_examples "responses for no matches"
    end
  end
end
