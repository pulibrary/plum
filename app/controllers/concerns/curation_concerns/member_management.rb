module CurationConcerns::MemberManagement
  extend ActiveSupport::Concern

  included do
    def structure
      parent_presenter
      @members = presenter.member_presenters
      @logical_order = presenter.logical_order_object
    end

    def save_structure
      structure = { "label": params["label"], "nodes": params["nodes"] }
      # Conversion to GlobalID is required so ActiveJob can serialize the curation_concern type as a param
      gid = GlobalID::Locator.locate curation_concern.to_global_id
      SaveStructureJob.perform_later(gid, structure)
      head 200
    end
  end
end
