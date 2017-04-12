require 'rails_helper'

RSpec.describe "vocabulary_collections/new", type: :view do
  before(:each) do
    assign(:vocabulary_collection, VocabularyCollection.new)
  end

  it "renders new vocabulary_collection form" do
    render

    assert_select "form[action=?][method=?]", vocabulary_collections_path, "post" do
      assert_select "input#vocabulary_collection_label,[name=?]", "vocabulary_collection[label,]"
      assert_select "select#vocabulary_collection_vocabulary_id[name=?]", "vocabulary_collection[vocabulary_id]"
    end
  end
end
