module GeoWorks
  class EventsGenerator
    class_attribute :services

    # Array of event generator services.
    # - GeoblacklightEventGenerator: synchronizes with geoblacklight instance.
    # - GeoserverEventGenerator: synchronizes with geoserver instance.
    self.services = [
      GeoblacklightEventGenerator,
      GeoserverEventGenerator
    ]

    delegate :record_created, to: :generators
    delegate :record_deleted, to: :generators
    delegate :record_updated, to: :generators
    delegate :derivatives_created, to: :generators

    def generators
      @generators ||= CompositeGenerator.new(
        services.map(&:new)
      )
    end
  end
end
