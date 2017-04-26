class HyraxShowPresenter < Hyrax::WorkShowPresenter
  delegate :viewing_hint, :viewing_direction, :logical_order, :logical_order_object, :ocr_language, :source_jsonld, :member_of_collection_ids, :workflow_state, to: :solr_document
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

  def export_as_jsonld
    source_or_basic_jsonld.merge(local_fields).to_json
  end

  def export_as_nt
    RDF::Graph.new.from_jsonld(export_as_jsonld).dump(:ntriples)
  end

  def export_as_ttl
    RDF::Graph.new.from_jsonld(export_as_jsonld).dump(:ttl)
  end

  private

    def source_or_basic_jsonld
      source_jsonld.nil? ? { title: title.first } : JSON.parse(source_jsonld)
    end

    def local_fields
      {
        '@context': 'https://bibdata.princeton.edu/context.json',
        '@id': obj_url,
        memberOf: collection_objects,
        scopeNote: portion_note,
        navDate: nav_date,
        edm_rights: solr_document.rights_statement,
        identifier: identifier
      }.reject { |_, v| v.nil? || v.try(:empty?) }
    end

    def obj_url
      Rails.application.routes.url_helpers.send "hyrax_#{model_name.singular}_url", id
    end

    def col_url(id)
      Rails.application.routes.url_helpers.collection_url id
    end

    def collection_objects
      member_of_collection_ids.zip(collection).map { |arr| { '@id': col_url(arr.first), title: arr.last } }
    end

    def logical_order_factory
      @logical_order_factory ||= WithProxyForObject::Factory.new(member_presenters)
    end
end
