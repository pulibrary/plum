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
    remote_ead = RemoteEad.new(source_metadata_identifier)
    begin
      self.source_metadata = remote_ead.source
    rescue => e
      logger.error("Record ID #{source_metadata_identifier} is malformed. Error:")
      logger.error("#{e.class}: #{e.message}")
    end
    self.attributes = remote_ead.attributes
  end

  # Retrieves MARC recrord from bibdata service
  #  * stores the full MARC record in source_metadata
  #  * extracts title, creator, date, and publisher from the MARC and sets those fields accordingly
  def apply_bibdata
    remote_bibdata = RemoteBibdata.new(source_metadata_identifier)

    begin
      self.source_metadata = remote_bibdata.source
    rescue => e
      logger.error("Record ID #{source_metadata_identifier} is malformed. Error:")
      logger.error("#{e.class}: #{e.message}")
    end
    self.attributes = remote_bibdata.attributes
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
