class ManifestBuilder
  class ManifestHelper
    include ActionDispatch::Routing::PolymorphicRoutes
    include Rails.application.routes.url_helpers

    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end
end
