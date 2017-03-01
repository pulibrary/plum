module Workflow
  class RemoveFromGeoBlacklight
    def self.call(target:, **)
      ::DeliverToGeoBlacklight.new(target).delete
    end
  end
end
