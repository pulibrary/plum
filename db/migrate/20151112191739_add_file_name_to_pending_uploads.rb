class AddFileNameToPendingUploads < ActiveRecord::Migration
  def change
    add_column :pending_uploads, :file_name, :string
  end
end
