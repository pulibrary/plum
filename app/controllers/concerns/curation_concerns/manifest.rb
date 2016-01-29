module CurationConcerns::Manifest
  extend ActiveSupport::Concern

  included do
    def manifest
      respond_to do |f|
        f.json do
          render json: manifest_builder
        end
      end
    end

    def deny_access(exception)
      if exception.action == :manifest && !current_user
        render json: AuthManifestBuilder.auth_services(login_url, nil), status: 401
      elsif !current_user
        session['user_return_to'.freeze] = request.url
        redirect_to login_url, alert: exception.message
      else
        super
      end
    end
  end

  private

    def presenter
      @presenter ||=
        begin
          _, document_list = search_results(params)
          curation_concern = document_list.first
          raise CanCan::AccessDenied.new(nil, params[:action].to_sym) unless curation_concern
          @presenter = show_presenter.new(curation_concern, current_ability)
        end
    end

    def manifest_builder
      PolymorphicManifestBuilder.new(presenter, ssl: request.ssl?, services: AuthManifestBuilder.auth_services(login_url, logout_url))
    end

    def login_url
      main_app.user_omniauth_authorize_url(:cas)
    end

    def logout_url
      current_user.nil? ? nil : main_app.destroy_user_session_url
    end
end
