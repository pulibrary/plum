class ManifestBuilder
  class LogoBuilder
    def initialize(ssl: false)
      @host = "#{ssl ? 'https' : 'http'}://#{Plum.default_url_options[:host]}"
    end

    def apply(manifest)
      manifest.logo = ActionController::Base.helpers.image_url('pul_logo_icon.png', host: @host)
      manifest
    end
  end
end
