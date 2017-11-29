# frozen_string_literal: true
class RightsStatementRenderer < Hyrax::Renderers::RightsAttributeRenderer
  def initialize(rights_statement, rights_note, options = {})
    super(:rights, rights_statement, options)
    @rights_note = if !rights_note.nil? && RightsStatementService.new.notable?(rights_statement)
                     rights_note
                   else
                     []
                   end
  end

  def render
    markup = ''

    return markup if !values.present? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute #{field}")
    Array(values).each do |value|
      markup << "<li#{html_attributes(attributes)}>#{rights_attribute_to_html(value.to_s)}</li>"
    end
    markup << %(</ul>)
    markup << simple_format(RightsStatementService.new.definition(values.first))
    @rights_note.each do |note|
      markup << %(<p>#{note}</p>) unless note.blank?
    end
    markup << simple_format(I18n.t('rights.boilerplate'))
    markup << %(</td></tr>)
    markup.html_safe
  end

  def rights_attribute_to_html(value)
    %(<a href=#{ERB::Util.h(value)} target="_blank">#{RightsStatementService.new.label(value)}</a>)
  end
end
