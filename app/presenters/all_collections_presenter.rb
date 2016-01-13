class AllCollectionsPresenter < CollectionShowPresenter
  def initialize(current_ability = nil)
    @current_ability = current_ability
  end

  def title
    "Plum Collections"
  end

  def description
    "All collections which are a part of Plum."
  end

  def creator
    nil
  end

  private

    def ordered_ids
      ActiveFedora::SolrService.query("active_fedora_model_ssi:Collection", rows: 10_000, fl: "id").map { |x| x["id"] }
    end
end
