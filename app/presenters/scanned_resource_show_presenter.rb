class ScannedResourceShowPresenter < CurationConcernsShowPresenter
  def file_presenter_class
    ::FileSetPresenter
  end

  def file_set_ids
    ordered_ids
  end

  def pending_uploads
    @pending_uploads ||= PendingUpload.where(curation_concern_id: id)
  end
end
