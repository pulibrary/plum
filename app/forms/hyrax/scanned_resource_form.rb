# frozen_string_literal: true
module Hyrax
  class ScannedResourceForm < ::Hyrax::HyraxForm
    self.model_class = ::ScannedResource
    self.terms += [:viewing_direction, :viewing_hint]

    def multiple?(field)
      return false if ['rights_statement'].include?(field.to_s)
      super
    end
  end
end
