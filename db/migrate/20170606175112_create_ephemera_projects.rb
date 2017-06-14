class CreateEphemeraProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :ephemera_projects do |t|
      t.string :name

      t.timestamps
    end
  end
end
