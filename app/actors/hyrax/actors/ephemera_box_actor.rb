# Generated via
#  `rails generate hyrax:work EphemeraBox`
module Hyrax
  module Actors
    class EphemeraBoxActor < Hyrax::Actors::BaseActor
      def create(attributes)
        curation_concern.ephemera_project = attributes.delete(:ephemera_project_id)
        super
      end
    end
  end
end
