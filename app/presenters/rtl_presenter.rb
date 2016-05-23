class RTLPresenter < ::Blacklight::DocumentPresenter
  def render_field_value(value = nil, field_config = nil)
    field_config ||= Blacklight::Configuration::Field.new
    field_config.separator_options ||= {
      words_connector: "<br/>",
      last_word_connector: "<br/>",
      two_words_connector: "<br/>"
    }
    super
  end

  def render_document_show_field_value(*args)
    to_list(super)
  end

  def render_index_field_value(*args)
    to_list(super)
  end

  def render_document_index_label(*args)
    to_list(super)
  end

  private

    def to_list(values)
      string = "<ul>"
      values.split("<br/>").each do |value|
        string << "<li dir=\"#{value.dir}\">#{value}</li>"
      end
      string << "</ul>"
      string.html_safe
    end
end
