require 'rails_helper'

RSpec.describe "vocabulary_terms/show", type: :view do
  before(:each) do
    @vocabulary_term = assign(:vocabulary_term, FactoryGirl.create(:vocabulary_term))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Literacy/)
    expect(rendered).to match(/http:\/\/id.loc.gov\/authorities\/subjects\/sh85077482/)
    expect(rendered).to match(/LAE Subjects/)
    expect(rendered).to match(/Education/)
  end
end
