module CurationConcerns
  class ScannedResourceForm < ::CurationConcerns::CurationConcernsForm
    self.model_class = ::ScannedResource
    self.terms += [:viewing_direction, :viewing_hint, :alternative_title, :digital_date, :usage_right, :volume_and_issue_no, :sort_title, :published, :physical_description, :series, :publication_place, :date_published, :lccn_call_number, :local_call_number, :copyright_holder, :responsibility_note, :digital_collection, :owning_institution, :funding, :digital_specifications, :author]
  end
end
