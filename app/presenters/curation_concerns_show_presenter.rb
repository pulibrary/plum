class CurationConcernsShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, :state, :type, :identifier, :workflow_note, to: :solr_document

  def state_badge
    StateBadge.new(type, state).render
  end
end
