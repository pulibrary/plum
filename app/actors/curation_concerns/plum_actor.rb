module CurationConcerns
  class PlumActor < CurationConcerns::BaseActor
    include ::CurationConcerns::WorkActorBehavior
    def update
      super.tap do |result|
        messenger.record_updated(curation_concern) if result
      end
    end

    private

      def messenger
        @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
      end
  end
end
