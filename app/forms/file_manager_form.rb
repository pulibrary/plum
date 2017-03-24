class FileManagerForm < Hyrax::Forms::FileManagerForm
  self.terms += [:viewing_direction, :viewing_hint, :ocr_language, :start_canvas]

  def pending_uploads
    model.pending_uploads.where(fileset_id: nil)
  end
end
