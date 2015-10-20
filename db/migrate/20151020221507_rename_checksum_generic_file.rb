class RenameChecksumGenericFile < ActiveRecord::Migration
  def change
    rename_column :checksum_audit_logs, :generic_file_id, :file_set_id
    rename_index :checksum_audit_logs, :by_generic_file_id_and_file_id, :by_file_set_id_and_file_id
  end
end
