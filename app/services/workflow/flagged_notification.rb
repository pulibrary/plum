# frozen_string_literal: true
module Workflow
  class FlaggedNotification < AbstractNotification
    protected

      def message
        "The following #{type} has been flagged by #{user.user_key}:"
      end

      def state
        'Flagged'
      end

    private

      def users_to_notify
        super << user
      end
  end
end
