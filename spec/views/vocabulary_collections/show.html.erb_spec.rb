require 'rails_helper'

RSpec.describe "vocabulary_collections/show", type: :view do
  before(:each) do
    @vocabulary_collection = assign(:vocabulary_collection, FactoryGirl.create(:vocabulary_collection))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Education/)
    expect(rendered).to match(/LAE Subjects/)
  end
end
