require 'rails_helper'

describe SearchController do
  subject { described_class }

  context "#search" do
    describe "when a id and q are given" do
      before do
        allow(PairtreeDerivativePath).to receive(:derivative_path_for_reference).and_return("spec/fixtures/files/test_json.json")
      end
      it "will return page" do
        file_set = FactoryGirl.build(:file_set, title: ["Studio C"])
        allow(file_set).to receive(:ocr_text).and_return("Studio")
        file_set.save
        resource = FactoryGirl.build(:scanned_resource, title: ["Rooms"])
        resource.ordered_members << file_set
        resource.save!
        get :search, id: resource.id, q: "Studio"
        expect(response).to be_success
      end
    end
    describe "when an id and q are given but no word boundary file exists" do
      it "will return page" do
        file_set = FactoryGirl.build(:file_set, title: ["Dinning Room"])
        allow(file_set).to receive(:ocr_text).and_return("Table")
        file_set.save
        resource = FactoryGirl.build(:scanned_resource, title: ["Places to Eat"])
        resource.ordered_members << file_set
        resource.save!
        get :search, id: resource.id, q: "Table"
        expect(response).to be_success
      end
    end
    describe "when no id is given" do
      it "will return API description page" do
        get :index
        expect(response).to be_success
      end
    end
  end
end
