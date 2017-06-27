# Generated via
#  `rails generate hyrax:work EphemeraFolder`

module Hyrax
  class EphemeraFoldersController < Hyrax::HyraxController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = EphemeraFolder
    self.show_presenter = EphemeraFolderPresenter
    skip_load_and_authorize_resource only: ::SearchBuilder.show_actions

    def after_create_response
      params[:save_and_create_another] ? create_another : super
    end

    def after_update_response
      params[:save_and_create_another] ? create_another : super
    end

    def create_another
      redirect_to polymorphic_path([main_app, :new, :hyrax, :parent, :ephemera_folder],
                                   parent_id: params[:parent_id], create_another: curation_concern.id)
    end

    def new
      curation_concern.attributes = ActiveFedora::Base.find(params[:create_another]).attributes
        .except("id", "barcode", "folder_number", "state") if params[:create_another]
      super
    end
  end
end
