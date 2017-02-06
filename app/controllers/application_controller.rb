class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  before_action :vary_header
  before_action do
    resource = controller_path.singularize.tr('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors to the application controller.
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

    def vary_header
      response.headers["Vary"] = "Accept"
    end
end
