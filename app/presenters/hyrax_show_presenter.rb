class HyraxShowPresenter < Hyrax::WorkShowPresenter
  delegate :viewing_hint, :viewing_direction, :logical_order, :logical_order_object, :ocr_language, to: :solr_document
  delegate(*ScannedResource.properties.values.map(&:term), to: :solr_document, allow_nil: true)
  delegate(*ScannedResource.properties.values.map { |x| "#{x.term}_literals" }, to: :solr_document, allow_nil: true)

  def logical_order_object
    @logical_order_object ||=
      logical_order_factory.new(logical_order, nil, logical_order_factory)
  end

  def start_canvas
    Array.wrap(solr_document.start_canvas).first
  end

  def member_presenter_factory
    ::EfficientMemberPresenterFactory.new(solr_document, current_ability, request)
  end

  private

    def logical_order_factory
      @logical_order_factory ||= WithProxyForObject::Factory.new(member_presenters)
    end
end
