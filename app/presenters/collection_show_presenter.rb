class CollectionShowPresenter < Hyrax::CollectionPresenter
  include Hyrax::Serializers
  delegate :id, :title, :exhibit_id, :date_created, to: :solr_document, allow_nil: true

  delegate :title, :description, :creator, :contributor, :subject, :publisher, :language,
           :embargo_release_date, :lease_expiration_date, :rights, to: :solr_document,
                                                                   allow_nil: true

  def member_presenters
    @member_presenters ||=
      begin
        ordered_docs.map do |doc|
          file_presenter_class.new(doc, current_ability)
        end
      end
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
    def ordered_docs
      @ordered_docs ||= ActiveFedora::SolrService.query("member_of_collection_ids_ssim:#{id}", rows: 10_000).map { |x| SolrDocument.new(x) }
    end

    def file_presenter_class
      MultiVolumeWorkShowPresenter::DynamicShowPresenter.new
    end
end
