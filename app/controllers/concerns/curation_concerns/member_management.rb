module CurationConcerns::MemberManagement
  extend ActiveSupport::Concern

  included do
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
end
