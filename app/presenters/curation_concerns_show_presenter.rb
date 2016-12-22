class CurationConcernsShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :viewing_hint, :viewing_direction, :state, :type, :identifier, :workflow_note, :logical_order, :logical_order_object, :ocr_language, :thumbnail_id, :source_metadata_identifier, :collection, to: :solr_document
  delegate :flaggable?, to: :state_badge_instance
  delegate(*ScannedResource.properties.values.map(&:term), to: :solr_document, allow_nil: true)
  delegate(*ScannedResource.properties.values.map { |x| "#{x.term}_literals" }, to: :solr_document, allow_nil: true)

  def state_badge
    state_badge_instance.render
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

  def page_title
    Array.wrap(title).first
  end

  def full_title
    [title, responsibility_note].map { |t| Array.wrap(t).first }.select { |t| !t.blank? }.join(' / ')
  end

  def display_call_number
    Array.wrap(lccn_call_number.present? ? lccn_call_number : local_call_number).first
  end

  def start_canvas
    Array.wrap(solr_document.start_canvas).first
  end

  private

    def logical_order_factory
      @logical_order_factory ||= WithProxyForObject::Factory.new(member_presenters)
    end

    def state_badge_instance
      StateBadge.new(type, state)
    end

    def renderer_for(_field, options)
      if options[:render_as]
        find_renderer_class(options[:render_as])
      else
        ::AttributeRenderer
      end
    end
end
