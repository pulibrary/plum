# Generated via
#  `rails generate curation_concerns:work ScannedBook`
class ScannedBook < ActiveFedora::Base
  include ::CurationConcerns::GenericWorkBehavior
  include ::CurationConcerns::BasicMetadata
  include PulMetadataServices::ExternalMetadataSource
  include ::NoidBehaviors

  property :portion_note, predicate: ::RDF::URI.new(::RDF::DC.description), multiple: false
  property :description, predicate: ::RDF::URI.new(::RDF::DC.abstract), multiple: false
  property :access_policy, predicate: ::RDF::URI.new(::RDF::DC.accessRights), multiple: false
  property :use_and_reproduction, predicate: ::RDF::URI.new(::RDF::DC.rights), multiple: false
  property :source_metadata_identifier, predicate: ::RDF::URI.new('http://library.princeton.edu/terms/metadata_id'), multiple: false
  property :source_metadata, predicate: ::RDF::URI.new('http://library.princeton.edu/terms/source_metadata'), multiple: false

  validates :source_metadata_identifier, presence: { message: 'You must provide a source metadata id.' }
  validates :access_policy, presence: { message: 'You must choose an Access Policy statement.' }
  validates :use_and_reproduction, presence: { message: 'You must provide a use statement.' }

  # Retrieves EAD recrord from pulfa
  #  * stores the full EAD record in source_metadata
  #  * extracts title, creator, date, and publisher from the EAD and sets those fields accordingly
  def apply_pulfa_data
    ead_source = retrieve_from_pulfa
    self.source_metadata = ead_source
    ead_record = ScannedBook.negotiate_ead(ead_source)
    self.title = ScannedBook.title_from_ead(ead_record)
    self.creator = ScannedBook.creator_from_ead(ead_record)
    self.date_created = ScannedBook.date_from_ead(ead_record)
    self.publisher = ScannedBook.publisher_from_ead(ead_record)
  end

  # Retrieves MARC recrord from bibdata service
  #  * stores the full MARC record in source_metadata
  #  * extracts title, creator, date, and publisher from the MARC and sets those fields accordingly
  def apply_bibdata
    marc_source = retrieve_from_bibdata
    begin
      self.source_metadata = marc_source
    rescue => e
      logger.error("Record ID #{source_metadata_identifier} is malformed. Error:")
      logger.error("#{e.class}: #{e.message}")
    end
    marc_record = ScannedBook.negotiate_record(marc_source)
    self.title = ScannedBook.title_from_marc(marc_record)
    self.creator = ScannedBook.creator_from_marc(marc_record)
    self.date_created = [ScannedBook.date_from_marc(marc_record)]
    self.publisher = ScannedBook.publisher_from_marc(marc_record)
  end

  def retrieve_from_pulfa
    response = pulfa_connection.get(source_metadata_identifier.tr('_', '/') + ".xml?scope=record")
    response.body
  end

  def pulfa_connection
    Faraday.new(url: 'http://findingaids.princeton.edu/collections/')
  end

  def bibdata_connection
    Faraday.new(url: 'http://bibdata.princeton.edu/bibliographic/')
  end

  def retrieve_from_bibdata
    response = bibdata_connection.get(source_metadata_identifier)
    logger.info("Fetching #{source_metadata_identifier}")
    response.body
  end

  def refresh_metadata
    apply_external_metadata
  end

  def apply_external_metadata
    if bibdata?
      apply_bibdata
    else
      apply_pulfa_data
    end
  end

  private

    # http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
    def bibdata?
      source_metadata_identifier =~ /\A[-+]?\d+\z/
    end
end
