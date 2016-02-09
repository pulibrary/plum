class HoldingLocationRenderer < CurationConcerns::AttributeRenderer
  def initialize(value, options = {})
    super(:location, value, options)
  end

  def value_html
    Array(values).map do |value|
      attribute_value_to_html(value)
    end.join("")
  end

  private

    def attribute_value_to_html(value)
      loc = HoldingLocationService.find(value)
      li_value %(#{loc.label}<br/>Contact at <a href="mailto:#{loc.email}">#{loc.email}</a>,
                 <a href="tel:#{loc.phone}">#{loc.phone}</a>)
    end
end
