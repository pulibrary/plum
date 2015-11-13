class ScannedResourceShowPresenter < CurationConcernsShowPresenter
  delegate :has?, :first, to: :solr_document
  def file_presenter_class
    ::FileSetPresenter
  end

  def pending_uploads
    @pending_uploads ||= PendingUpload.where(curation_concern_id: id)
  end
end
