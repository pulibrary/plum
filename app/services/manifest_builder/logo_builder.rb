class ManifestBuilder
  class LogoBuilder
    include ActionView::Helpers::AssetUrlHelper

    def initialize(ssl: false)
      @ssl = ssl
    end

    def apply(manifest)
      manifest.logo = "#{protocol}://#{host}#{asset_path('assets/pul_logo_icon.png')}"
      manifest
    end

    def protocol
      @ssl ? 'https' : 'http'
    end

    def host
      Plum.default_url_options[:host]
    end
  end
end
