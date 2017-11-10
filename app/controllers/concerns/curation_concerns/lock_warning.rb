module CurationConcerns::LockWarning
  extend ActiveSupport::Concern

  included do
    def lock_warning
      flash.now[:alert] = "This object is currently queued for processing." if lock_id? && presenter.lock?
    end

    private

      def lock_id?
        presenter.respond_to?(:id) && !presenter.try(:id).blank?
      end
  end
end
