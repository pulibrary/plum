# Generated via
#  `rails generate hyrax:work EphemeraFolder`
module Hyrax
  module Actors
    class EphemeraFolderActor < Hyrax::Actors::BaseActor
      def create(attributes)
        box_id = attributes.delete(:box_id)
        assign_box(box_id) && super
      end

      def update(attributes)
        box_id = attributes.delete(:box_id)
        assign_box(box_id) && super
      end

      private

        # Maps from box ID box
        def assign_box(box_id)
          return true unless box_id
          # grab/save collections this user has no edit access to
          collections_not_boxes = curation_concern.member_of_collections.select { |coll| !coll.is_a?(EphemeraBox) }
          curation_concern.member_of_collections = [::EphemeraBox.find(box_id)]
          curation_concern.member_of_collections.concat collections_not_boxes
        end
    end
  end
end
