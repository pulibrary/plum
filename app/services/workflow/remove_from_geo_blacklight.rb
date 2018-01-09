# frozen_string_literal: true
module Workflow
  class RemoveFromGeoBlacklight
    def self.call(target:, **)
      ::DeliverToGeoBlacklight.new(target).delete
    end
  end
end
