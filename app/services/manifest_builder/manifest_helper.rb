# frozen_string_literal: true
class ManifestBuilder
  class ManifestHelper
    include ActionDispatch::Routing::PolymorphicRoutes
    include Rails.application.routes.url_helpers

    def default_url_options
      Plum.default_url_options
    end
  end
end
