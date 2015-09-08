class ScannedBookShowPresenter < CurationConcerns::GenericWorkShowPresenter
  delegate :date_created, to: :solr_document
end
