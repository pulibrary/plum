class LinksToChild < SimpleDelegator
  def link_child(child)
    if child.model_name.singular == "scanned_resource"
      view_helper.link_to child.to_s, helper.curation_concerns_member_scanned_resource_path(id, child.id)
    else
      view_helper.link_to child.to_s, helper.polymorphic_path(child)
    end
  end

  delegate :class, to: :__getobj__

  class Factory
    attr_reader :parent_factory

    def initialize(parent_factory)
      @parent_factory ||= parent_factory
    end

    def new(*args)
      LinksToChild.new(parent_factory.new(*args))
    end
  end

  private

    def helper
      @helper ||= ManifestBuilder::ManifestHelper.new
    end

    def view_helper
      @view_helper ||= ActionController::Base.helpers
    end
end
