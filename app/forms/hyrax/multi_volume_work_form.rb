# frozen_string_literal: true
module Hyrax
  class MultiVolumeWorkForm < ::Hyrax::HyraxForm
    self.model_class = ::MultiVolumeWork
    self.terms += [:viewing_direction, :viewing_hint]

    def multiple?(field)
      return false if ['rights_statement'].include?(field.to_s)
      super
    end
  end
end
