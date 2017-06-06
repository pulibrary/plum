require 'rails_helper'

RSpec.describe "ephemera_fields/index", type: :view do
  before(:each) do
    assign(:ephemera_fields, [
      EphemeraField.create!(
        :name => "Name",
        :ephemera_project_id => 2,
        :vocabulary => nil
      ),
      EphemeraField.create!(
        :name => "Name",
        :ephemera_project_id => 2,
        :vocabulary => nil
      )
    ])
  end

  it "renders a list of ephemera_fields" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
