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
    shared_examples "returns 404 responses" do
      context "in html" do
        let(:format) { 'html' }
        it "returns a 404 response" do
          expect(response.status).to eq(404)
          expect(response).to render_template(file: "#{Rails.root}/public/404.html")
        end
      end
      context "in json" do
        let(:format) { 'json' }
        it "returns a 404 response" do
          expect(response.status).to eq(404)
          expect(JSON.parse(response.body)['error']).to eq 'not_found'
        end
      end
    end
    context "with an invalid id" do
      before(:each) do
        get :default, id: 'BHR940', format: format
      end
      include_examples "returns 404 responses"
    end
    context "with an unmatched id" do
      before(:each) do
        unmatched_id = scanned_resource.source_metadata_identifier
        scanned_resource.destroy!
        get :default, id: unmatched_id, format: format
      end
      include_examples "returns 404 responses"
    end
  end
end
