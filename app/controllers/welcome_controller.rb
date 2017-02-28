class WelcomeController < ApplicationController
  def index
    @hyrax = Hyrax::ClassifyConcern.new.all_curation_concern_classes
  end
end
