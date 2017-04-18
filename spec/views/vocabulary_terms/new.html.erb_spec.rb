require 'rails_helper'

RSpec.describe "vocabulary_terms/new", type: :view do
  before(:each) do
    assign(:vocabulary_term, VocabularyTerm.new)
  end

  it "renders new vocabulary_term form" do
    render

    assert_select "form[action=?][method=?]", vocabulary_terms_path, "post" do
      assert_select "input#vocabulary_term_label[name=?]", "vocabulary_term[label]"
      assert_select "input#vocabulary_term_uri[name=?]", "vocabulary_term[uri]"
      assert_select "input#vocabulary_term_code[name=?]", "vocabulary_term[code]"
      assert_select "input#vocabulary_term_tgm_label[name=?]", "vocabulary_term[tgm_label]"
      assert_select "input#vocabulary_term_lcsh_label[name=?]", "vocabulary_term[lcsh_label]"
      assert_select "select#vocabulary_term_vocabulary_id[name=?]", "vocabulary_term[vocabulary_id]"
    end
  end
end
