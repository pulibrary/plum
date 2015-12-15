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
      collection_ids = params[curation_concern_name].delete(:collection_ids) || []

      if actor_create
        (add_to_collections(collection_ids) && curation_concern.save) if collection_ids.any?
        after_create_response
      else
        setup_collections
        setup_form
        respond_to do |wants|
          wants.html { render 'new', status: :unprocessable_entity }
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
        end
      end
    end

    def actor_create
      return actor.create
    rescue StandardError
      curation_concern.errors.add :source_metadata_identifier, "Error retrieving metadata"
      logger.debug "Error retrieving metadata: #{params[curation_concern_name]['source_metadata_identifier']}"
      return false
    end

    def update
      add_to_collections(params[curation_concern_name].delete(:collection_ids))
      super
    end
  end

  private

    def add_to_collections(new_collection_ids)
      return true unless new_collection_ids

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
        collection.members << curation_concern
        collection.save
        collection.update_index
      end
      true
    end
end
