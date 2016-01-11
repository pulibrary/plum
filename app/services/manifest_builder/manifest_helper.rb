class ManifestBuilder
  class ManifestHelper
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::PolymorphicRoutes
  end
end

