module CurationConcerns
  class FileSetsController < ApplicationController
    include CurationConcerns::FileSetsControllerBehavior

    def show_presenter
      ::FileSetPresenter
    end
  end
end
