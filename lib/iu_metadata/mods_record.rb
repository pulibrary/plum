module IuMetadata
  class ModsRecord
    def initialize(source)
      @source = source
    end

    attr_reader :source
  end
end
