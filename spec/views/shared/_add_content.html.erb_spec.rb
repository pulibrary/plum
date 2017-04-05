require 'rails_helper'

RSpec.describe "shared/_add_content.html.erb" do
  let(:user) { FactoryGirl.create(:admin) }
  before do
    allow(controller).to receive(:current_user).and_return(user)
    render partial: "shared/add_content"
  end
  it "displays a link to role management" do
    expect(rendered).to have_link "Manage Roles"
    expect(rendered).to have_link "Workflow Roles"
  end
  context "for a non-admin" do
    let(:user) { FactoryGirl.create(:image_editor) }
    it "doesn't display a link to role management" do
      expect(rendered).not_to have_link "Manage Roles"
      expect(rendered).not_to have_link "Workflow Roles"
    end
  end
end
