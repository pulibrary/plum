module Hyrax
  class MultiVolumeWorkForm < ::Hyrax::HyraxForm
    self.model_class = ::MultiVolumeWork
    self.terms += [:viewing_direction, :viewing_hint]
  end
end
