class HoldingLocationRenderer < Hyrax::Renderers::AttributeRenderer
  def initialize(value, options = {})
    super(:location, value, options)
  end

  def value_html
    Array(values).map do |value|
      location_string(HoldingLocationService.find(value))
    end.join("")
  end

  private

    def attribute_value_to_html(value)
      loc = HoldingLocationService.find(value)
      li_value location_string(loc)
    end

    def location_string(loc)
      "#{loc.label}<br/>#{loc.address}<br/>
Contact at <a href=\"mailto:#{loc.email}\">#{loc.email}</a>,
                 <a href=\"tel:#{loc.phone}\">#{loc.phone}</a>".html_safe
    end
end
