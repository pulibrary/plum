# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "ephemera_fields/new", type: :view do
  before do
    @project = assign(:ephemera_project, EphemeraProject.create!(name: "My Project"))
    @ephemera_field = assign(:ephemera_field, EphemeraField.new)
  end

  it "renders new ephemera_field form" do
    render

    assert_select "form[action=?][method=?]", ephemera_project_ephemera_fields_path(@project), "post" do
      assert_select "select#ephemera_field_name[name=?]", "ephemera_field[name]"
      assert_select "select#ephemera_field_vocabulary_id[name=?]", "ephemera_field[vocabulary_id]"
    end
  end
end
