class MultiVolumeWorkShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, to: :solr_document
end
