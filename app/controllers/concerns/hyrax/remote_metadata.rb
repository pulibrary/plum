module Hyrax::RemoteMetadata
  extend ActiveSupport::Concern

  private

    def decorator
      if wants_to_update_remote_metadata?
        CompositeDecorator.new(UpdatesMetadata, super)
      else
        super
      end
    end

    def wants_to_update_remote_metadata?
      params[:action] == "create" || params[:refresh_remote_metadata]
    end
end
