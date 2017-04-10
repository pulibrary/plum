require 'rails_helper'

RSpec.describe "vocabularies/edit", type: :view do
  before(:each) do
    @vocabulary = assign(:vocabulary, FactoryGirl.create(:vocabulary))
  end

  it "renders the edit vocabulary form" do
    render

    assert_select "form[action=?][method=?]", vocabulary_path(@vocabulary), "post" do
      assert_select "input#vocabulary_label[name=?]", "vocabulary[label]"
    end
  end
end
