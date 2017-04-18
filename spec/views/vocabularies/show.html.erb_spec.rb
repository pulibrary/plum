require 'rails_helper'

RSpec.describe "vocabularies/show", type: :view do
  before(:each) do
    @parent = FactoryGirl.create(:vocabulary, label: 'LAE Subjects')
    @vocabulary = assign(:vocabulary, FactoryGirl.create(:vocabulary, label: 'Education', parent: @parent))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/LAE Subjects/)
    expect(rendered).to match(/Education/)
  end
end
