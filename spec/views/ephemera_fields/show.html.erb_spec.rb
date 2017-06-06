require 'rails_helper'

RSpec.describe "ephemera_fields/show", type: :view do
  before(:each) do
    @ephemera_field = assign(:ephemera_field, EphemeraField.create!(
      :name => "Name",
      :ephemera_project_id => 2,
      :vocabulary => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
