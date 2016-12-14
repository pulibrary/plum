
class GeoConcernsShowPresenter < GeoConcerns::GeoConcernsShowPresenter
  delegate :state, :type, :identifier, :collection, to: :solr_document
  delegate :flaggable?, to: :state_badge_instance

  def state_badge
    state_badge_instance.render
  end

  def rights_statement
    RightsStatementRenderer.new(solr_document.rights_statement, solr_document.rights_note).render
  end

  def holding_location
    HoldingLocationRenderer.new(solr_document.holding_location).render
  end

  private

    def state_badge_instance
      StateBadge.new(type, state)
    end
end
