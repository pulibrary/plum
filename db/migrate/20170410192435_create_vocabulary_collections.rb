class CreateVocabularyCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :vocabulary_collections do |t|
      t.string :label
      t.references :vocabulary, foreign_key: true

      t.timestamps
    end
  end
end
