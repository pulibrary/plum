class ResourceIdentifier
  ##
  # Encapsulates what it takes to combine multiple timestamps into one string.
  class CompositeTimestamp
    attr_reader :timestamps
    def initialize(timestamps)
      @timestamps = timestamps || []
    end

    def to_s
      timestamps.select(&:present?).join("-|-")
    end
  end
end
