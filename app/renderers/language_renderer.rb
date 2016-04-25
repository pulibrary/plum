class LanguageRenderer < CurationConcerns::AttributeRenderer
  def initialize(values, options = {})
    super(:language, values, options)
  end

  private

    def attribute_value_to_html(value)
      li_value LanguageService.label(value)
    end
end
