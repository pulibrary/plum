module Workflow
  class UpdatedEvent
    def self.call(target:, **)
      messenger.record_updated(target)
    end

    def self.messenger
      ManifestEventGenerator.new(Plum.messaging_client)
    end
  end
end
