require "rails_helper"

RSpec.describe VocabulariesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/vocabularies").to route_to("vocabularies#index")
    end

    it "routes to #new" do
      expect(get: "/vocabularies/new").to route_to("vocabularies#new")
    end

    it "routes to #show" do
      expect(get: "/vocabularies/1").to route_to("vocabularies#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/vocabularies/1/edit").to route_to("vocabularies#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/vocabularies").to route_to("vocabularies#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/vocabularies/1").to route_to("vocabularies#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/vocabularies/1").to route_to("vocabularies#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/vocabularies/1").to route_to("vocabularies#destroy", id: "1")
    end
  end
end
