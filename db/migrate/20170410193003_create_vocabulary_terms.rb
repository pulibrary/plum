class CreateVocabularyTerms < ActiveRecord::Migration[5.0]
  def change
    create_table :vocabulary_terms do |t|
      t.string :label
      t.string :uri
      t.string :code
      t.string :tgm_label
      t.string :lcsh_label
      t.references :vocabulary, foreign_key: true
      t.references :vocabulary_collection, foreign_key: true

      t.timestamps
    end
  end
end
