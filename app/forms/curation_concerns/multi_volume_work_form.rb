module CurationConcerns
  class MultiVolumeWorkForm < ::CurationConcerns::CurationConcernsForm
    self.model_class = ::MultiVolumeWork
    self.terms += [:viewing_direction, :viewing_hint]
  end
end
