# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "vocabulary_terms/index", type: :view do
  let(:vocabulary_terms) { [
    FactoryGirl.create(:vocabulary_term, label: "Label 1"),
    FactoryGirl.create(:vocabulary_term, label: "Test", uri: 'http://example.org/test', code: 'test',
                                         tgm_label: "TGM Label", lcsh_label: "LCSH Label")
  ] }
  before do
    assign(:vocabulary_terms, vocabulary_terms)
  end

  it "renders a list of vocabulary_terms" do
    render
    assert_select "tr>td", text: "Label 1", count: 1
    assert_select "tr>td", text: "Test", count: 1
    assert_select "tr>td", text: "http:\/\/id.loc.gov\/authorities\/subjects\/sh85077482", count: 1
    assert_select "tr>td", text: "http:\/\/example.org\/test", count: 1
    assert_select "tr>td", text: vocabulary_terms.first.vocabulary.label, count: 2
  end
end
