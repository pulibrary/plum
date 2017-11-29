# frozen_string_literal: true
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

  def size
    # TODO: can we do a double or triple join to find FileSets attached to ScannedResources that are members
    #       of a collection, and/or members of a MultiVolumeWork that are members of a collection?
    nil
  end

  def total_items
    ActiveFedora::SolrService.count("member_of_collection_ids_ssim:#{id}")
  end

  private

    # TODO: Extract this to ActiveFedora::Aggregations::ListSource
    def ordered_docs
      @ordered_docs ||= ActiveFedora::SolrService.query("member_of_collection_ids_ssim:#{id}", rows: 10_000).map { |x| SolrDocument.new(x) }
    end

    def file_presenter_class
      ::DynamicShowPresenter.new
    end
end
