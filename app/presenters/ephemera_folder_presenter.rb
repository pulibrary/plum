class EphemeraFolderPresenter < HyraxShowPresenter
  self.collection_presenter_class = DynamicShowPresenter.new
  delegate :folder_number, to: :solr_document
end
