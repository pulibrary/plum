module Hyrax
  class ScannedResourceForm < ::Hyrax::HyraxForm
    self.model_class = ::ScannedResource
    self.terms += [:viewing_direction, :viewing_hint]
  end
end
