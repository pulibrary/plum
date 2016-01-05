##
# Returns a unique resource identifier for the current state of a given scanned
#   resource ID in Fedora.
class ResourceIdentifier
  attr_reader :id, :repository
  def initialize(id, repository = nil)
    @id = id
    @repository = repository || SolrRepository
  end

  # Unique key of the object pointed to by ID's state.
  def to_s
    @digest ||= Digest::MD5.hexdigest(timestamp)
  end

  # Reload's this resource identifier so it's recalculated by #to_s.
  def reload
    @digest = nil
    @timestamp = nil
    self
  end

  # Combined timestamp of this resource and all its state dependancies.
  def timestamp
    @timestamp ||= CompositeTimestamp.new([solr_record.timestamp, dependency_record.timestamp]).to_s
  end

  private

    def dependency_record
      if solr_record.dependant_ids.blank?
        NoDependencies.instance
      else
        ResourceIdentifier.new(solr_record.dependant_ids)
      end
    end

    def solr_record
      repository.find(id)
    end
end
