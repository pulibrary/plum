module CurationConcerns
  class PlumActor < CurationConcerns::BaseActor
    include ::CurationConcerns::WorkActorBehavior
    def update(attributes)
      super.tap do |result|
        messenger.record_updated(curation_concern) if result
      end
    rescue JSONLDRecord::MissingRemoteRecordError => err
      bad_record_id(err)
    end

    def create(attributes)
      super
    rescue JSONLDRecord::MissingRemoteRecordError => err
      bad_record_id(err)
    end

    private

      def messenger
        @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
      end

      def bad_record_id(err)
        curation_concern.errors.add :source_metadata_identifier, "Error retrieving metadata"
        Rails.logger.debug "Error retrieving metadata: #{curation_concern.source_metadata_identifier}: #{err}"
        false
      end
  end
end
