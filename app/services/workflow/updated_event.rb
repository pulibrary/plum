module Workflow
  class UpdatedEvent
    def self.call(target:, **)
      target.save
      messenger.record_updated(target)
      true
    end

    def self.messenger
      ManifestEventGenerator.new(Plum.messaging_client)
    end
  end
end
