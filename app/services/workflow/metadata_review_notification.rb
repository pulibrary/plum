module Workflow
  class MetadataReviewNotification < AbstractNotification
    protected

      def state
        'Metadata Review'
      end

    private

      def users_to_notify
        super << user
      end
  end
end
