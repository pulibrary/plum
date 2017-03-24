class ChangePendingUploads < ActiveRecord::Migration[5.0]
  def up
    change_column :pending_uploads, :upload_set_id, :string
  end
  def down
    change_column :pending_uploads, :upload_set_id, :integer
  end
end
