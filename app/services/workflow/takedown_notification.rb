module Workflow
  class TakedownNotification < AbstractNotification
    protected

      def message
        "The following #{type} has been taken down by #{user.user_key}:"
      end

      def state
        'Takedown'
      end

    private

      def users_to_notify
        super << user
      end
  end
end
