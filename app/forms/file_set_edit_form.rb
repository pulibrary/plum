class FileSetEditForm < Hyrax::Forms::FileSetEditForm
  include SingleValuedForm
  self.terms += [:viewing_hint]
  class_attribute :single_valued_fields
  self.single_valued_fields = [:viewing_hint]
end
