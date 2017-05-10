class MapSetShowPresenter < HyraxShowPresenter
  include PlumAttributes

  def parent_work_presenters
    # filter out collection presenters
    member_of_presenters.select do |member|
      member.model_name.name != "Collection"
    end
  end

  def member_of_presenters
    Hyrax::PresenterFactory.build_presenters(member_of_ids,
                                             collection_presenter_class,
                                             *presenter_factory_arguments)
  end

  def member_of_ids
    ActiveFedora::SolrService.query("{!field f=member_ids_ssim}#{id}",
                                    fl: ActiveFedora.id_field).map { |x| x.fetch(ActiveFedora.id_field) }
  end

  def attribute_to_html(field, options = {})
    if field == :coverage
      GeoWorks::CoverageRenderer.new(field, send(field), options).render
    else
      super field, options
    end
  end
end
