module Discovery
  class DocumentPath < GeoWorks::Discovery::DocumentBuilder::DocumentPath
    # Overrides method to get protocol outside of controller context.
    # Needed for delivering to geoblacklight from workflow method.
    def protocol
      default_url_options.fetch(:protocol, 'http').to_sym
    end

    # Overrides method to get host outside of controller context.
    # Needed for delivering to geoblacklight from workflow method.
    def host
      default_url_options[:host]
    end

    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end
end
