require 'rails_helper'

RSpec.describe "ephemera_fields/edit", type: :view do
  before(:each) do
    @ephemera_field = assign(:ephemera_field, EphemeraField.create!(
      :name => "MyString",
      :ephemera_project_id => 1,
      :vocabulary => nil
    ))
  end

  it "renders the edit ephemera_field form" do
    render

    assert_select "form[action=?][method=?]", ephemera_field_path(@ephemera_field), "post" do

      assert_select "input#ephemera_field_name[name=?]", "ephemera_field[name]"

      assert_select "input#ephemera_field_ephemera_project_id[name=?]", "ephemera_field[ephemera_project_id]"

      assert_select "input#ephemera_field_vocabulary_id[name=?]", "ephemera_field[vocabulary_id]"
    end
  end
end
