class CollectionShowPresenter < CurationConcerns::CollectionPresenter
  include CurationConcerns::Serializers
  delegate :id, :title, :exhibit_id, to: :solr_document

  def file_presenters
    @file_sets ||= CurationConcerns::PresenterFactory.build_presenters(ordered_ids,
                                                                       file_presenter_class,
                                                                       current_ability)
  end

  def viewing_hint
    nil
  end

  def logical_order
    {}
  end

  def label
    []
  end

  private

    # TODO: Extract this to ActiveFedora::Aggregations::ListSource
    def ordered_ids
      Array(solr_document["member_ids_ssim"])
    end

    # Override this method if you want to use an alternate presenter class for the files
    def file_presenter_class
      ScannedResourceShowPresenter
    end
end
