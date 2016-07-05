module RTLPresenter
  extend ActiveSupport::Concern

  included do
    def field_config(field)
      super(field).tap do |config|
        config.separator_options = { words_connector: "<br/>", last_word_connector: "<br/>", two_words_connector: "<br/>" } unless config.separator_options
      end
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
end
