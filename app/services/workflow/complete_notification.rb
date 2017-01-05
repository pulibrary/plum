module Workflow
  class CompleteNotification < AbstractNotification
    protected

      def state
        'Complete'
      end

    private

      def users_to_notify
        super << user
      end
  end
end
