class ResourceIdentifier
  ##
  # A null object for handling the case where there are no dependencies needed
  # to calculate the resource identifier.
  class NoDependencies
    include Singleton
    def timestamp
      nil
    end
  end
end
