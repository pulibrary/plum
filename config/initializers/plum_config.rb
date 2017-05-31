module Plum
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  def messaging_client
    MessagingClient.new(Plum.config['events']['server'])
  end

  def geoblacklight_messaging_client
    GeoblacklightMessagingClient.new(Plum.config['events']['server'])
  end

  private

    def config_yaml
      YAML.load(ERB.new(File.read("#{Rails.root}/config/config.yml")).result)[Rails.env]
    end

    module_function :config, :config_yaml, :messaging_client, :geoblacklight_messaging_client
end

Hydra::Derivatives.kdu_compress_recipes = Plum.config['jp2_recipes']

# Use custon GeoWorks document builders
GeoWorks::Discovery::DocumentBuilder.root_path_class = Discovery::DocumentPath
GeoWorks::Discovery::DocumentBuilder.services = [
  GeoWorks::Discovery::DocumentBuilder::BasicMetadataBuilder,
  GeoWorks::Discovery::DocumentBuilder::SpatialBuilder,
  GeoWorks::Discovery::DocumentBuilder::DateBuilder,
  GeoWorks::Discovery::DocumentBuilder::ReferencesBuilder,
  Discovery::LayerInfoBuilder,
  Discovery::SlugBuilder,
  Discovery::IIIFBuilder,
  Discovery::WxsBuilder,
  Discovery::RelationshipBuilder
]

GeoWorks::EventsGenerator.services = [
  PlumGeoblacklightEventGenerator,
  GeoWorks::EventsGenerator::GeoserverEventGenerator
]
