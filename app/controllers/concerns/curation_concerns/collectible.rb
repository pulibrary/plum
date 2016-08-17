module CurationConcerns::Collectible
  extend ActiveSupport::Concern

  included do
    def build_form
      setup_collections
      super
    end

    def setup_collections
      @collections = ::Collection.all.sort { |x, y| x.title <=> y.title }
    end

    def create
      if actor.create(attributes_for_actor)
        (add_to_collections(collection_id_params) && curation_concern.save) if collection_id_params.try(:any?)
        after_create_response
      else
        build_form
        respond_to do |wants|
          wants.html { render 'new', status: :unprocessable_entity }
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end
  end

  private

    def add_to_collections(new_collection_ids)
      return true if new_collection_ids.nil?
      new_collection_ids = Array(new_collection_ids).select(&:present?)

      previous_collections = []
      previous_collections = curation_concern.in_collections.map(&:id) unless curation_concern.in_collections.nil?

      # remove from old collections
      (previous_collections - new_collection_ids).each do |old_id|
        collection = Collection.find(old_id)
        collection.members.delete(curation_concern)
        collection.save
        collection.update_index
      end

      # add to new
      (new_collection_ids - previous_collections).each do |coll_id|
        collection = Collection.find(coll_id)
        collection.members << @curation_concern
        collection.save
        collection.update_index
      end
      true
    end
end
