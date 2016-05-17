class CurationConcernsShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :viewing_hint, :viewing_direction, :state, :type, :identifier, :workflow_note, :logical_order, :logical_order_object, :ocr_language, :thumbnail_id, :source_metadata_identifier, :collection, to: :solr_document
  delegate :flaggable?, to: :state_badge_instance
  delegate(*ScannedResource.properties.values.map(&:term), to: :solr_document, allow_nil: true)

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
    RightsStatementRenderer.new(solr_document.rights_statement, solr_document.rights_note).render
  end

  def holding_location
    HoldingLocationRenderer.new(solr_document.holding_location).render
  end

  def language
    Array.wrap(solr_document.language).map { |code| LanguageService.label(code) }
  end

  def date_created
    DateValue.new(solr_document.date_created).to_a
  end

  def attribute_to_html(field, options = {})
    unless respond_to?(field)
      Rails.logger.warn("#{self.class} attempted to render #{field}, but no method exists with that name.")
      return
    end
    AttributeRenderer.new(field, send(field), options).render
  end

  private

    def logical_order_factory
      @logical_order_factory ||= WithProxyForObject::Factory.new(member_presenters)
    end

    def state_badge_instance
      StateBadge.new(type, state)
    end
end
