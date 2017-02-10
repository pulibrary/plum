class AllCollectionsPresenter < CollectionShowPresenter
  def initialize(current_ability = nil)
    @current_ability = current_ability
  end

  def title
    ["Plum Collections"]
  end

  def description
    "All collections which are a part of Plum."
  end

  def creator
    nil
  end

  def exhibit_id
    nil
  end

  def member_presenters
    @member_presenters ||= super.select do |presenter|
      if presenter.current_ability
        presenter.current_ability.can?(:read, presenter.solr_document)
      else
        true
      end
    end
  end

  private

    # Override this method if you want to use an alternate presenter class for the files
    def file_presenter_class
      SparseCollectionShowPresenter
    end

    def current_ability
      @current_ability ||= nil
    end

    def ordered_docs
      @ordered_docs ||= ActiveFedora::SolrService.query("has_model_ssim:Collection", rows: 10_000).map { |x| SolrDocument.new(x) }
    end
end
