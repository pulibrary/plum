class AddParentToVocabularies < ActiveRecord::Migration[5.0]
  def change
    add_reference :vocabularies, :parent, Vocabulary: true, foreign_key: true
  end
end
