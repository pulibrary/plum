module CurationConcerns::MemberManagement
  extend ActiveSupport::Concern

  included do
    def bulk_edit
      @members = presenter.file_presenters
    end

    def save_order
      lock_manager.lock(curation_concern.id) do
        form = ReorderForm.new(curation_concern)
        form.order = params[:order]
        if form.save
          render json: { message: "Successfully updated order." }
        else
          render json: { message: form.errors.full_messages.to_sentence }, status: :bad_request
        end
      end
    end

    def structure
      @members = presenter.file_presenters
      @logical_order = presenter.logical_order_object
    end

    def save_structure
      curation_concern.logical_order.order = { "nodes": params["nodes"] }
      curation_concern.save
      head 200
    end
  end

  private

    def lock_manager
      @lock_manager ||= CurationConcerns::LockManager.new(
        CurationConcerns.config.lock_time_to_live,
        CurationConcerns.config.lock_retry_count,
        CurationConcerns.config.lock_retry_delay)
    end
end
