require 'rails_helper'

RSpec.describe PagesController do
  describe "robots" do
    it "renders robot.text" do
      get :robots, format: :text
      expect(response).to render_template "pages/robots"
    end
  end
end
