class CreatePendingUploads < ActiveRecord::Migration
  def change
    create_table :pending_uploads do |t|
      t.integer :curation_concern_id
      t.integer :upload_set_id

      t.timestamps null: false
    end
  end
end
