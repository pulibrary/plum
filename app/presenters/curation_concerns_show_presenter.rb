class CurationConcernsShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, :state, :type, :identifier, :workflow_note, :logical_order, :logical_order_object, to: :solr_document
  delegate :flaggable?, to: :state_badge_instance

  def state_badge
    state_badge_instance.render
  end

  def in_collections
    ActiveFedora::SolrService.query("active_fedora_model_ssi:Collection AND member_ids_ssim:#{id}")
      .map { |c| CurationConcerns::CollectionPresenter.new(SolrDocument.new(c), current_ability) }
  end

  def logical_order_object
    @logical_order_object ||=
      logical_order_factory.new(logical_order, nil, logical_order_factory)
  end

  def pending_uploads
    @pending_uploads ||= PendingUpload.where(curation_concern_id: id)
  end

  def rights_statement
    RightsStatementRenderer.new(solr_document.rights_statement).render
  end

  private

    def logical_order_factory
      @logical_order_factory ||= WithProxyForObject::Factory.new(file_presenters)
    end

    def state_badge_instance
      StateBadge.new(type, state)
    end
end
