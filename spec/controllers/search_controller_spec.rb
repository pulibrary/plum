require 'rails_helper'

describe SearchController do
  subject { described_class }

  context "#search" do
    describe "when a id is given" do
      it "will return page" do
        get :search, id: "123"
        expect(response).to be_success
      end
    end
  end
end
