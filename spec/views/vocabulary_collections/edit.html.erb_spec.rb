require 'rails_helper'

RSpec.describe "vocabulary_collections/edit", type: :view do
  before(:each) do
    @vocabulary_collection = assign(:vocabulary_collection, FactoryGirl.create(:vocabulary_collection))
  end

  it "renders the edit vocabulary_collection form" do
    render

    assert_select "form[action=?][method=?]", vocabulary_collection_path(@vocabulary_collection), "post" do
      assert_select "input#vocabulary_collection_label,[name=?]", "vocabulary_collection[label,]"
      assert_select "select#vocabulary_collection_vocabulary_id[name=?]", "vocabulary_collection[vocabulary_id]"
    end
  end
end
