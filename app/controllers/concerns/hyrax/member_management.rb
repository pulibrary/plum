module Hyrax::MemberManagement
  extend ActiveSupport::Concern

  included do
    def structure
      parent_presenter
      @members = presenter.member_presenters
      @logical_order = presenter.logical_order_object
    end

    def save_structure
      curation_concern.logical_order.destroy(eradicate: true)
      curation_concern.reload
      curation_concern.logical_order.order = { "label": params["label"], "nodes": params["nodes"] }
      curation_concern.save!
      head 200
    rescue StandardError => e
      Rails.logger.warn "Error: #{e}"
    end
  end
end
