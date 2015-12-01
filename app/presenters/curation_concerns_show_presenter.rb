class CurationConcernsShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, :state, :identifier, to: :solr_document

  def state_badge
    StateBadge.new(solr_document).render
  end
end
