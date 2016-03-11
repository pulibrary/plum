class CreateProcessedEvents < ActiveRecord::Migration
  def change
    create_table :processed_events do |t|
      t.integer :event_id

      t.timestamps null: false
    end
  end
end
