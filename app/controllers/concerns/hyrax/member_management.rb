module Hyrax::MemberManagement
  extend ActiveSupport::Concern

  included do
    def structure
      parent_presenter
      @members = presenter.member_presenters
      @logical_order = presenter.logical_order_object
    end

    def save_structure
      begin
        curation_concern.logical_order.destroy(eradicate: true)
      rescue Ldp::Gone
        ActiveFedora::Base.eradicate("#{curation_concern.id}/logical_order")
      end
      curation_concern.reload
      curation_concern.logical_order.order = { "label": params.to_unsafe_h["label"], "nodes": params.to_unsafe_h["nodes"] }
      curation_concern.save!
      head 200
    rescue StandardError => e
      Rails.logger.warn "Error: #{e.message}"
    end
  end
end
