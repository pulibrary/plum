class EfficientMemberPresenterFactory < Hyrax::MemberPresenterFactory
  self.file_presenter_class = ::FileSetPresenter

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

  # TODO: Extract this to ActiveFedora::Aggregations::ListSource
  def ordered_ids
    @ordered_ids ||= begin
                       ActiveFedora::SolrService.query("proxy_in_ssi:#{id}",
                                                       rows: 10_000,
                                                       fl: "ordered_targets_ssim")
                       .flat_map { |x| x.fetch("ordered_targets_ssim", []) }
                     end
  end
end
