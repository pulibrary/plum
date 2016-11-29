class ImageWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::GeoConcerns::ImageWorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::GeoConcerns::BasicGeoMetadata
  self.valid_child_concerns = [RasterWork]
end
