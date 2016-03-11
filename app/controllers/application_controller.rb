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

  # Adds CurationConcerns behaviors to the application controller.
  include CurationConcerns::ApplicationControllerBehavior
  include Hydra::Controller::ControllerBehavior
  include CurationConcerns::ThemedLayoutController
  with_themed_layout '1_column'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    return super unless super.nil?
    return nil unless authorization_header.start_with?('Bearer')
    TokenService.user_from_token(decryption_key, authorization_header.gsub(/Bearer /, ''))
  end

  private

    def vary_header
      response.headers["Vary"] = "Accept"
    end

    def decryption_key
      @description_key ||= Rails.application.secrets.secret_key_base
    end

    def authorization_header
      request.headers['Authorization'] || ''
    end
end
