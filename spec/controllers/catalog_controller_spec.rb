require 'rails_helper'

RSpec.describe CatalogController do
  describe "scanned book display" do
    it "shows parent-less scanned resources" do
      resource = FactoryGirl.create(:scanned_resource)
      get :index, q: ""

      expect(document_ids).to eq [resource.id]
    end
    it "shows child-less parent resources" do
      work = FactoryGirl.create(:multi_volume_work)

      get :index, q: ""
      expect(document_ids).to eq [work.id]
    end
    it "hides scanned resources with parents" do
      work = FactoryGirl.build(:multi_volume_work)
      resource = FactoryGirl.create(:scanned_resource)
      work.ordered_members << resource
      work.save

      get :index, q: ""
      expect(document_ids).to eq [work.id]
    end
    it "finds parents with child metadata" do
      work = FactoryGirl.build(:multi_volume_work, title: ["Alpha"])
      resource = FactoryGirl.create(:scanned_resource, title: ["Beta"])
      work.ordered_members << resource
      work.save

      get :index, q: "Beta"
      expect(document_ids).to eq [work.id]
    end

    def document_ids
      assigns[:document_list].map do |x|
        x["id"]
      end
    end
  end
end
