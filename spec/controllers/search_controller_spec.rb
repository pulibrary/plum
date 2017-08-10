require 'rails_helper'

describe SearchController do
  subject { described_class }

  context "#search" do
    describe "when a id and q are given" do
      it "will return page" do
        get :search, id: "123", q: "term"
        expect(response).to be_success
      end
    end
  end
end
