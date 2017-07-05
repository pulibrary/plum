require 'rails_helper'

RSpec.describe "vocabularies/index", type: :view do
  before(:each) do
    assign(:vocabularies, [
      FactoryGirl.create(:vocabulary, label: 'Label 1'),
      FactoryGirl.create(:vocabulary, label: 'Label 2')
    ])
  end

  it "renders a list of vocabularies" do
    render
    assert_select "tr>td", text: "Label 1".to_s, count: 1
    assert_select "tr>td", text: "Label 2".to_s, count: 1
  end
end
