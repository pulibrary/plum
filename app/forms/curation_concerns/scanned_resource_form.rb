module CurationConcerns
  class ScannedResourceForm < ::CurationConcerns::CurationConcernsForm
    self.model_class = ::ScannedResource
    self.terms += [:viewing_direction, :viewing_hint]
  end
end
