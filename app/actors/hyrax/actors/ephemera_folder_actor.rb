# Generated via
#  `rails generate hyrax:work EphemeraFolder`
module Hyrax
  module Actors
    class EphemeraFolderActor < PlumActor
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
          curation_concern.member_of_collections.concat [::EphemeraBox.find(box_id)]
        end
    end
  end
end
