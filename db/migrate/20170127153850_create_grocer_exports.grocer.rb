# This migration comes from grocer (originally 20170119220038)
class CreateGrocerExports < ActiveRecord::Migration[5.0]
  def change
    create_table :grocer_exports do |t|
      t.string :pid
      t.integer :job
      t.string :status
      t.datetime :last_error
      t.datetime :last_success
      t.string :logfile

      t.timestamps
    end
    add_index :grocer_exports, :pid, unique: true
  end
end
