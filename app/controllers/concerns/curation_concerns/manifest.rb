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
        render json: {}, status: 401
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
      Rails.cache.fetch("manifest/#{presenter.id}/#{ResourceIdentifier.new(presenter.id)}") do
        PolymorphicManifestBuilder.new(presenter, ssl: request.ssl?).to_json
      end
    end

    def login_url
      main_app.user_omniauth_authorize_url(:cas)
    end
end
