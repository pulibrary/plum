class ChangePendingUploadCurationConcernId < ActiveRecord::Migration
  def up
    change_column :pending_uploads, :curation_concern_id, :string
  end

  def down
    change_column :pending_uploads, :curation_concern_id, :integer
  end
end
