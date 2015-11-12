class PendingUpload < ActiveRecord::Base
  validates :curation_concern_id, :upload_set_id, :file_name, :file_path, presence: true
end
