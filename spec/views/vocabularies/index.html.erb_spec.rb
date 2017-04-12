require 'rails_helper'

RSpec.describe "vocabularies/index", type: :view do
  before(:each) do
    assign(:vocabularies, [
      FactoryGirl.create(:vocabulary),
      FactoryGirl.create(:vocabulary, label: 'Label')
    ])
  end

  it "renders a list of vocabularies" do
    render
    assert_select "tr>td", text: "LAE Subjects".to_s, count: 1
    assert_select "tr>td", text: "Label".to_s, count: 1
  end
end
