module LanguageService

  def self.label(id)
    lang = ISO_639.find_by_code(id).try(:english_name) || id
  end
end
