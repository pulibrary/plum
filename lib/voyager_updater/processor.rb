module VoyagerUpdater
  class Processor
    attr_reader :ids
    def initialize(ids)
      @ids = ids
    end

    def run!
      Rails.logger.info "Processing updates for IDs: #{ids.join(', ')}" unless ids.empty?
      ids.each do |id|
        begin
          resource = ActiveFedora::Base.find(id)
          resource.apply_remote_metadata
          resource.save!
          messenger.record_updated(resource)
        rescue
          Rails.logger.info "Unable to process changed Voyager record #{id}"
        end
      end
    end

    private

      def messenger
        @messenger ||= ManifestEventGenerator.new(Plum.messaging_client)
      end
  end
end
