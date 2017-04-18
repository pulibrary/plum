require 'rails_helper'

RSpec.describe "vocabulary_terms/edit", type: :view do
  before(:each) do
    @vocabulary_term = assign(:vocabulary_term, FactoryGirl.create(:vocabulary_term))
  end

  it "renders the edit vocabulary_term form" do
    render

    assert_select "form[action=?][method=?]", vocabulary_term_path(@vocabulary_term), "post" do
      assert_select "input#vocabulary_term_label[name=?]", "vocabulary_term[label]"
      assert_select "input#vocabulary_term_uri[name=?]", "vocabulary_term[uri]"
      assert_select "input#vocabulary_term_code[name=?]", "vocabulary_term[code]"
      assert_select "input#vocabulary_term_tgm_label[name=?]", "vocabulary_term[tgm_label]"
      assert_select "input#vocabulary_term_lcsh_label[name=?]", "vocabulary_term[lcsh_label]"
      assert_select "select#vocabulary_term_vocabulary_id[name=?]", "vocabulary_term[vocabulary_id]"
    end
  end
end
