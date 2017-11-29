# frozen_string_literal: true
class ManifestBuilder
  class HyraxManifestHelper
    include Hyrax::Engine.routes.url_helpers
    include ActionDispatch::Routing::PolymorphicRoutes

    def default_url_options
      Plum.default_url_options
    end
  end
end
