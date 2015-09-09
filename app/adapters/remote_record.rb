##
# An adapter class to handle the difference between PUL's opinions on metadata
# and CC's "open world" assumptions. IE the date_created field is single-valued
# in MARC records, but multi-valued in Curation Concerns.
class RemoteRecord < SimpleDelegator
  class << self
    def retrieve(id)
      new(PulMetadataServices::Client.retrieve(id))
    end
  end

  def attributes
    result = super
    result[:date_created] = Array(result[:date_created])
    result
  end
end
