require "rails_helper"

RSpec.describe EphemeraProjectsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ephemera_projects").to route_to("ephemera_projects#index")
    end

    it "routes to #new" do
      expect(get: "/ephemera_projects/new").to route_to("ephemera_projects#new")
    end

    it "routes to #show" do
      expect(get: "/ephemera_projects/1").to route_to("ephemera_projects#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/ephemera_projects/1/edit").to route_to("ephemera_projects#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/ephemera_projects").to route_to("ephemera_projects#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/ephemera_projects/1").to route_to("ephemera_projects#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ephemera_projects/1").to route_to("ephemera_projects#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ephemera_projects/1").to route_to("ephemera_projects#destroy", id: "1")
    end
  end
end
