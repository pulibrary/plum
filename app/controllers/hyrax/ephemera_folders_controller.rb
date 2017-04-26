# Generated via
#  `rails generate hyrax:work EphemeraFolder`

module Hyrax
  class EphemeraFoldersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = EphemeraFolder
    self.show_presenter = EphemeraFolderPresenter

    def after_create_response
      respond_to do |wants|
        wants.html do
          # Calling `#t` in a controller context does not mark _html keys as html_safe
          flash[:notice] = view_context.t('hyrax.works.create.after_create_html', application_name: view_context.application_name)
          redirect_to contextual_path(curation_concern, parent_presenter)
        end
        wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
      end
    end
  end
end
