class ManifestBuilder
  class LogoBuilder
    attr_reader :record
    def initialize(record, ssl: false)
      @record = record
      @host = "#{ssl ? 'https' : 'http'}://#{Plum.default_url_options[:host]}"
    end

    def apply(manifest)
      manifest.logo = ActionController::Base.helpers.image_url(logo, host: @host)
      manifest
    end

    private

      def logo
        if record.respond_to?(:rights_statement_uri) && record.rights_statement_uri == 'http://cicognara.org/microfiche_copyright'
          'vatican.png'
        else
          'pul_logo_icon.png'
        end
      end
  end
end
