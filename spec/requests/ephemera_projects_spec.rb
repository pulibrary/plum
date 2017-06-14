require 'rails_helper'

RSpec.describe "EphemeraProjects", type: :request do
  describe "GET /ephemera_projects" do
    it "works! (now write some real specs)" do
      get ephemera_projects_path
      expect(response).to have_http_status(200)
    end
  end
end
