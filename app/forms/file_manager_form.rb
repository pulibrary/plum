class FileManagerForm < Hyrax::Forms::FileManagerForm
  self.terms += [:viewing_direction, :viewing_hint, :ocr_language, :start_canvas]
  delegate :pending_uploads, to: :model
end
