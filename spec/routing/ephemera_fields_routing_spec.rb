require "rails_helper"

RSpec.describe EphemeraFieldsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/ephemera_fields").to route_to("ephemera_fields#index")
    end

    it "routes to #new" do
      expect(:get => "/ephemera_fields/new").to route_to("ephemera_fields#new")
    end

    it "routes to #show" do
      expect(:get => "/ephemera_fields/1").to route_to("ephemera_fields#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/ephemera_fields/1/edit").to route_to("ephemera_fields#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/ephemera_fields").to route_to("ephemera_fields#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/ephemera_fields/1").to route_to("ephemera_fields#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/ephemera_fields/1").to route_to("ephemera_fields#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/ephemera_fields/1").to route_to("ephemera_fields#destroy", :id => "1")
    end

  end
end
