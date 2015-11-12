class AddFilePathToPendingUploads < ActiveRecord::Migration
  def change
    add_column :pending_uploads, :file_path, :string
  end
end
