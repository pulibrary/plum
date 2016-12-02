module GeoConcerns
  module Messaging
    def config
      @config ||= config_yaml.with_indifferent_access
    end

    def messenger
      GeoConcerns::EventsGenerator.new
    end

    def geoblacklight_client
      rabbit_client
    end

    def geoserver_client
      local_client
    end

    private

      def config_yaml
        config_file = "#{Rails.root}/config/geo_concerns_messaging.yml"
        YAML.load(ERB.new(File.read(config_file)).result)[Rails.env]
      end

      def local_client
        GeoConcerns::LocalMessagingClient.new
      end

      def rabbit_client
        GeoConcerns::RabbitMessagingClient.new(Messaging.config['events']['server'])
      end

      module_function :config, :config_yaml, :messenger, :local_client,
                      :rabbit_client, :geoblacklight_client, :geoserver_client
  end
end
