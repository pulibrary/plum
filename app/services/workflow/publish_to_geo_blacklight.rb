module Workflow
  class PublishToGeoBlacklight
    def self.call(target:, **)
      ::DeliverToGeoBlacklight.new(target).update
    end
  end
end
