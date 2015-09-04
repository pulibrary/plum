# Generated via
#  `rails generate curation_concerns:work ScannedBook`
class ScannedBook < ActiveFedora::Base
  include ::CurationConcerns::GenericWorkBehavior
  include ::CurationConcerns::BasicMetadata
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

  def refresh_metadata
    apply_external_metadata
  end

  def apply_external_metadata
    remote_data = remote_ead_factory.new(source_metadata_identifier)
    begin
      self.source_metadata = remote_data.source
    rescue => e
      logger.error("Record ID #{source_metadata_identifier} is malformed. Error:")
      logger.error("#{e.class}: #{e.message}")
    end
    self.attributes = remote_data.attributes
  end

  private

  def remote_ead_factory
    if bibdata?
      RemoteBibdata
    else
      RemoteEad
    end
  end

  # http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
  def bibdata?
    source_metadata_identifier =~ /\A[-+]?\d+\z/
  end
end
