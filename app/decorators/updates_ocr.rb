# frozen_string_literal: true
class UpdatesOCR < Decorator
  delegate :class, to: :__getobj__

  def save
    changed = ocr_language_changed?
    super.tap do
      regenerate_derivatives if changed
    end
  end

  private

    def regenerate_derivatives
      file_set_ids.each do |f|
        RunOCRJob.perform_later(f)
      end
    end
end
