require 'rails_helper'

RSpec.describe "vocabularies/show", type: :view do
  before(:each) do
    @vocabulary = assign(:vocabulary, FactoryGirl.create(:vocabulary))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/LAE Subjects/)
  end
end
