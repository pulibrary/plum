class CreateTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :templates do |t|
      t.text :params

      t.timestamps
    end
  end
end
