class CurationConcernsShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, :state, :type, :identifier, :workflow_note, :logical_order, :logical_order_object, to: :solr_document

  def state_badge
    StateBadge.new(type, state).render
  end

  def logical_order_object
    @logical_order_object ||=
      logical_order_factory.new(logical_order, nil, logical_order_factory)
  end

  private

    def logical_order_factory
      @logical_order_factory ||= WithProxyForObject::Factory.new(file_presenters)
    end
end
