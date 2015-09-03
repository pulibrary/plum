class ApplicationController < ActionController::Base
  before_action do
    resource = controller_path.singularize.tr('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller

  # Adds CurationConcerns behaviors to the application controller.
  include CurationConcerns::ApplicationControllerBehavior
  include Hydra::Controller::ControllerBehavior
  include CurationConcerns::ThemedLayoutController
  with_themed_layout '1_column'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
