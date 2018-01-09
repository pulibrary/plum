# frozen_string_literal: true
module Workflow
  class FinalReviewNotification < AbstractNotification
    protected

      def state
        'Final Review'
      end

    private

      def users_to_notify
        super << user
      end
  end
end
