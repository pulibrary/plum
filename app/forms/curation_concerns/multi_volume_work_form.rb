module CurationConcerns
  class MultiVolumeWorkForm < ::CurationConcerns::CurationConcernsForm
    self.model_class = ::MultiVolumeWork
    self.terms += [:viewing_direction, :viewing_hint, :sort_title, :published, :physical_description, :series, :publication_place, :issued, :lccn_call_number, :local_call_number, :copyright_holder, :responsibility_note]
  end
end
