class AddFilesetIdToPendingUploads < ActiveRecord::Migration[5.0]
  def change
    add_column :pending_uploads, :fileset_id, :string
  end
end
