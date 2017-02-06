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

  # @param [Array<String>] ids a list of ids to build presenters for
  # @param [Class] presenter_class the type of presenter to build
  # @return [Array<presenter_class>] presenters for the ordered_members (not filtered by class)
  def member_presenters(ids = ordered_ids, presenter_class = composite_presenter_class)
    @member_presenters ||=
      begin
        ordered_docs.select { |x| ids.include?(x.id) }.map do |doc|
          presenter_class.new(doc, *presenter_factory_arguments)
        end
      end
  end

  def ordered_docs
    @ordered_docs ||= begin
                       ActiveFedora::SolrService.query("{!join from=ordered_targets_ssim to=id}proxy_in_ssi:#{id}", rows: 100_000).map { |x| SolrDocument.new(x) }.sort_by { |x| ordered_ids.index(x.id) }
                     end
  end

  private

    def logical_order_factory
      @logical_order_factory ||= WithProxyForObject::Factory.new(member_presenters)
    end
end
