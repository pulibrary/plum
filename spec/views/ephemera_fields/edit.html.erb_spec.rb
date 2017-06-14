require 'rails_helper'

RSpec.describe "ephemera_fields/edit", type: :view do
  before(:each) do
    @project = assign(:ephemera_project, EphemeraProject.create!(name: "My Project"))
    @vocab = Vocabulary.create!(label: "My Vocab")
    @ephemera_field = assign(:ephemera_field, EphemeraField.create!(
                                                name: "My Field",
                                                ephemera_project_id: @project.id,
                                                vocabulary: @vocab
    ))
  end

  it "renders the edit ephemera_field form" do
    render

    assert_select "form[action=?][method=?]", ephemera_project_ephemera_field_path(@project, @ephemera_field), "post" do
      assert_select "select#ephemera_field_name[name=?]", "ephemera_field[name]"
      assert_select "select#ephemera_field_vocabulary_id[name=?]", "ephemera_field[vocabulary_id]"
    end
  end
end
