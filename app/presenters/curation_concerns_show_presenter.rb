class CurationConcernsShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, :state, :type, :identifier, :workflow_note, :logical_order, :logical_order_object, to: :solr_document

  def state_badge
    StateBadge.new(type, state).render
  end

  def in_collections
    ActiveFedora::SolrService.query("active_fedora_model_ssi:Collection AND member_ids_ssim:#{id}")
      .map { |c| CurationConcerns::CollectionPresenter.new(SolrDocument.new(c), current_ability) }
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
