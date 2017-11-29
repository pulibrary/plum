# frozen_string_literal: true
module Plum
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  def messaging_client
    @messaging_client ||= MessagingClient.new(Plum.config['events']['server'])
  end

  def geoblacklight_messaging_client
    @geoblacklight_messaging_client ||= GeoblacklightMessagingClient.new(Plum.config['events']['server'])
  end

  def default_url_options
    @default_url_options ||= ActionMailer::Base.default_url_options
  end

  private

    def config_yaml
      YAML.safe_load(ERB.new(File.read("#{Rails.root}/config/config.yml")).result)[Rails.env]
    end

    module_function :config, :config_yaml, :messaging_client, :geoblacklight_messaging_client, :default_url_options
end

Hydra::Derivatives.kdu_compress_recipes = Plum.config['jp2_recipes']

# Use custon GeoWorks document builders
GeoWorks::Discovery::DocumentBuilder.root_path_class = Discovery::DocumentPath
GeoWorks::Discovery::DocumentBuilder.services = [
  GeoWorks::Discovery::DocumentBuilder::BasicMetadataBuilder,
  GeoWorks::Discovery::DocumentBuilder::SpatialBuilder,
  Discovery::DateBuilder,
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
