# frozen_string_literal: true
module Workflow
  class CompleteRecord
    def self.call(target:, **)
      ::CompleteRecord.new(target).complete
      true
    end
  end
end
