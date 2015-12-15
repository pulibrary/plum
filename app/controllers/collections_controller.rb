class CollectionsController < ApplicationController
  include CurationConcerns::CollectionsControllerBehavior

  def form_class
    CollectionEditForm
  end

  def presenter_class
    CollectionShowPresenter
  end
end
