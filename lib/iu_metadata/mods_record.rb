module IuMetadata
  class ModsRecord
    def initialize(id, source)
      @id = id
      @source = source
    end

    attr_reader :id, :source

    def attributes
      {}
    end
  end
end
