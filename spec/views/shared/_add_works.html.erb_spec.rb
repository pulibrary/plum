require 'rails_helper'

RSpec.describe "shared/_add_works.html.erb" do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    allow(controller).to receive(:current_user).and_return(user)
    render partial: "shared/add_works"
  end
  it "displays a link to role management" do
    expect(rendered).to have_link "Manage Roles"
  end
  context "for a non-admin" do
    let(:user) { FactoryGirl.create(:curation_concern_creator) }
    it "doesn't display a link to role management" do
      expect(rendered).not_to have_link "Manage Roles"
    end
  end
end
