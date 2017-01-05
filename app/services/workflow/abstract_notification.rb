# Adapted from Sufia
module Workflow
  class AbstractNotification
    include Rails.application.routes.url_helpers

    def self.send_notification(entity:, comment:, user:, recipients:)
      new(entity, comment, user, recipients).call
    end

    attr_reader :work_id, :title, :type, :comment, :user, :recipients

    def initialize(entity, comment, user, recipients)
      @work_id = entity.proxy_for_global_id.sub(/.*\//, '')
      @title = entity.proxy_for.title.first
      @type = entity.proxy_for.human_readable_type
      @comment = comment.respond_to?(:comment) ? comment.comment.to_s : ''
      @recipients = recipients
      @user = user
    end

    def call
      mail.deliver_later
    end

    protected

      def subject
        "[plum] #{type} #{work_id}: #{state}"
      end

      def message
        "The following #{type} has been moved to #{state} by #{user.user_key}:"
      end

      def state
        raise NotImplementedError, "Implement #state in a child class"
      end

    private

      def addresses
        users_to_notify.uniq.map(&:email)
      end

      def users_to_notify
        recipients.fetch('to', []) + recipients.fetch('cc', [])
      end

      def url
        url_for(curation_concern)
      end

      def curation_concern
        @curation_concern ||= ActiveFedora::Base.find(work_id)
      end

      def mail
        ReviewerMailer.notify(mailer_args)
      end

      def mailer_args
        {
          subject: subject,
          message: message,
          title: title,
          work_id: work_id,
          comment: comment,
          addresses: addresses,
          url: url
        }
      end
  end
end
