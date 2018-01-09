# frozen_string_literal: true
module LanguageService
  def self.label(id)
    ISO_639.find_by_code(id).try(:english_name) || id
  end
end
