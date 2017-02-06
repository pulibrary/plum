module Hyrax
  class ImageWorkForm < ::Hyrax::HyraxForm
    include ::GeoConcerns::BasicGeoMetadataForm
    include ::GeoConcerns::ExternalMetadataFileForm
    self.model_class = ::ImageWork
  end
end
