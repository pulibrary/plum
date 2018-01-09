# frozen_string_literal: true
require "rails_helper"

RSpec.describe AuthTokensController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/auth_tokens").to route_to("auth_tokens#index")
    end

    it "routes to #new" do
      expect(get: "/auth_tokens/new").to route_to("auth_tokens#new")
    end

    it "routes to #show" do
      expect(get: "/auth_tokens/1").to route_to("auth_tokens#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/auth_tokens/1/edit").to route_to("auth_tokens#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/auth_tokens").to route_to("auth_tokens#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/auth_tokens/1").to route_to("auth_tokens#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/auth_tokens/1").to route_to("auth_tokens#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/auth_tokens/1").to route_to("auth_tokens#destroy", id: "1")
    end
  end
end
