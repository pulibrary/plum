class CurationConcerns::VectorWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::ParentContainer
  include GeoConcerns::VectorWorksControllerBehavior
  include GeoConcerns::GeoblacklightControllerBehavior
  include GeoConcerns::MessengerBehavior
  self.curation_concern_type = VectorWork
end
