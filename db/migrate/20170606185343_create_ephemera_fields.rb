class CreateEphemeraFields < ActiveRecord::Migration[5.0]
  def change
    create_table :ephemera_fields do |t|
      t.string :name
      t.integer :ephemera_project_id
      t.references :vocabulary, foreign_key: true

      t.timestamps
    end
  end
end
