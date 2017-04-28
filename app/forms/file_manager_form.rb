class FileManagerForm < Hyrax::Forms::FileManagerForm
  include SingleValuedForm
  self.terms += [:viewing_direction, :viewing_hint, :ocr_language, :start_canvas]
  class_attribute :single_valued_fields
  self.single_valued_fields = [:viewing_hint, :viewing_direction, :start_canvas]

  def pending_uploads
    model.pending_uploads.where(fileset_id: nil)
  end
end
