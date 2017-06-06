require 'rails_helper'

RSpec.describe "ephemera_fields/new", type: :view do
  before(:each) do
    assign(:ephemera_field, EphemeraField.new(
      :name => "MyString",
      :ephemera_project_id => 1,
      :vocabulary => nil
    ))
  end

  it "renders new ephemera_field form" do
    render

    assert_select "form[action=?][method=?]", ephemera_fields_path, "post" do

      assert_select "input#ephemera_field_name[name=?]", "ephemera_field[name]"

      assert_select "input#ephemera_field_ephemera_project_id[name=?]", "ephemera_field[ephemera_project_id]"

      assert_select "input#ephemera_field_vocabulary_id[name=?]", "ephemera_field[vocabulary_id]"
    end
  end
end
