require 'rails_helper'

RSpec.describe "vocabularies/new", type: :view do
  before(:each) do
    assign(:vocabulary, Vocabulary.new)
  end

  it "renders new vocabulary form" do
    render

    assert_select "form[action=?][method=?]", vocabularies_path, "post" do
      assert_select "input#vocabulary_label[name=?]", "vocabulary[label]"
    end
  end
end
