class CreateVocabularies < ActiveRecord::Migration[5.0]
  def change
    create_table :vocabularies do |t|
      t.string :label

      t.timestamps
    end
  end
end
