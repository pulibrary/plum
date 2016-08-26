class RtlLinkedAttributeRenderer < AttributeRenderer
  def li_value(value)
    link_to(ERB::Util.h(value), search_path(value))
  end

  def li_markup(value, attributes)
    "<li#{html_attributes(attributes)} dir=#{value.dir}>#{attribute_value_to_html(value.to_s)}</li>"
  end

  def search_path(value)
    Rails.application.routes.url_helpers.search_catalog_path(
      search_field: search_field, q: ERB::Util.h(value))
  end

  def search_field
    options.fetch(:search_field, field)
  end
end
