require 'rails_helper'

RSpec.describe "vocabulary_terms/index", type: :view do
  before(:each) do
    assign(:vocabulary_terms, [
      FactoryGirl.create(:vocabulary_term),
      FactoryGirl.create(:vocabulary_term, label: "Test", uri: 'http://example.org/test', code: 'test',
                                           tgm_label: "TGM Label", lcsh_label: "LCSH Label")
    ])
  end

  it "renders a list of vocabulary_terms" do
    render
    assert_select "tr>td", text: "Literacy", count: 1
    assert_select "tr>td", text: "Test", count: 1
    assert_select "tr>td", text: "http:\/\/id.loc.gov\/authorities\/subjects\/sh85077482", count: 1
    assert_select "tr>td", text: "http:\/\/example.org\/test", count: 1
    assert_select "tr>td", text: "Education", count: 2
    assert_select "tr>td", text: "LAE Subjects", count: 2
  end
end
