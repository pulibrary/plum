module CurationConcerns::RemoteMetadata
  extend ActiveSupport::Concern

  included do
    def curation_concern
      if wants_to_update_remote_metadata?
        decorated_concern
      else
        @curation_concern
      end
    end
  end

  private

    def decorated_concern
      decorator.new(@curation_concern)
    end

    def decorator
      UpdatesMetadata
    end

    def wants_to_update_remote_metadata?
      params[:action] == "create" || params[:refresh_remote_metadata]
    end
end
