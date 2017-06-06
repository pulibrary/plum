class EphemeraBoxPresenter < HyraxShowPresenter
  delegate :barcode, :ephemera_project, :ephemera_project_name, to: :solr_document
  def member_presenters
    @member_presenters ||= Hyrax::PresenterFactory.build_presenters(member_ids,
                                                                    DynamicShowPresenter.new,
                                                                    *presenter_factory_arguments)
  end

  def member_ids
    @ordered_ids ||= begin
                       ActiveFedora::SolrService.query("member_of_collection_ids_ssim:#{id}",
                                                       rows: 10_000,
                                                       fl: "id")
                       .flat_map { |x| x.fetch("id", nil) }.compact
                     end
  end
end
