class AddParentToVocabularies < ActiveRecord::Migration[5.0]
  def change
    add_reference :vocabularies, :parent, Vocabulary: true
    add_foreign_key :vocabularies, :vocabularies, column: :parent_id
  end
end
