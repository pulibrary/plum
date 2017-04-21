module Workflow
  class UpdatedEvent
    def self.call(target:, **)
      return unless target.is_a?(ScannedResource) || target.is_a?(MultiVolumeWork)
      target.save
      messenger.record_updated(target)
      true
    end

    def self.messenger
      ManifestEventGenerator.new(Plum.messaging_client)
    end
  end
end
