# frozen_string_literal: true
module PlumAttributes
  delegate :state, :type, :identifier, :thumbnail_id, :source_metadata_identifier, :collection, :date, to: :solr_document

  def state_badge
    state_badge_instance.render
  end

  def pending_uploads
    @pending_uploads ||= PendingUpload.where(curation_concern_id: id)
  end

  def rights_statement
    RightsStatementRenderer.new(solr_document.rights_statement, solr_document.rights_note).render
  end

  def rights_statement_uri
    Array.wrap(solr_document.rights_statement).first
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

  def page_title
    Array.wrap(title).first
  end

  private

    def state_badge_instance
      StateBadge.new(self)
    end

    def renderer_for(_field, options)
      if options[:render_as]
        find_renderer_class(options[:render_as])
      else
        ::AttributeRenderer
      end
    end
end
