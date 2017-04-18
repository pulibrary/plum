class RemoveVocabularyCollectionFromVocabularyTerms < ActiveRecord::Migration[5.0]
  def change
    remove_reference :vocabulary_terms, :vocabulary_collection, foreign_key: true
  end
end
