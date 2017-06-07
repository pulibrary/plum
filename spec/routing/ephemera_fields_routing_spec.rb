require "rails_helper"

RSpec.describe EphemeraFieldsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/ephemera_projects/1/ephemera_fields/new").to route_to("ephemera_fields#new", ephemera_project_id: "1")
    end

    it "routes to #edit" do
      expect(get: "/ephemera_projects/1/ephemera_fields/1/edit").to route_to("ephemera_fields#edit", id: "1", ephemera_project_id: "1")
    end

    it "routes to #create" do
      expect(post: "/ephemera_projects/1/ephemera_fields").to route_to("ephemera_fields#create", ephemera_project_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/ephemera_projects/1/ephemera_fields/1").to route_to("ephemera_fields#update", id: "1", ephemera_project_id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ephemera_projects/1/ephemera_fields/1").to route_to("ephemera_fields#update", id: "1", ephemera_project_id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ephemera_projects/1/ephemera_fields/1").to route_to("ephemera_fields#destroy", id: "1", ephemera_project_id: "1")
    end
  end
end
