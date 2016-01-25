module HasPendingUploads
  def pending_uploads
    PendingUpload.where(curation_concern_id: id)
  end
end
