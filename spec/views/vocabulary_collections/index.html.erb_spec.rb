require 'rails_helper'

RSpec.describe "vocabulary_collections/index", type: :view do
  before(:each) do
    assign(:vocabulary_collections, [
      FactoryGirl.create(:vocabulary_collection),
      FactoryGirl.create(:vocabulary_collection, label: 'Economics')
    ])
  end

  it "renders a list of vocabulary_collections" do
    render
    assert_select "tr>td", text: "Education", count: 1
    assert_select "tr>td", text: "Economics", count: 1
    assert_select "tr>td", text: "LAE Subjects", count: 2
  end
end
