# Generated via
#  `rails generate curation_concerns:work ScannedBook`
class ScannedBook < ActiveFedora::Base
  include ::CurationConcerns::GenericWorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::NoidBehaviors

  property :sort_title, predicate: ::RDF::URI.new("http://opaquenamespace.org/ns/mods/titleForSort"), multiple: false
  property :portion_note, predicate: ::RDF::URI.new(::RDF::SKOS.scopeNote), multiple: false
  property :description, predicate: ::RDF::URI.new(::RDF::DC.abstract), multiple: false
  property :access_policy, predicate: ::RDF::URI.new(::RDF::DC.accessRights), multiple: false
  property :use_and_reproduction, predicate: ::RDF::URI.new(::RDF::DC.rights), multiple: false
  property :source_metadata_identifier, predicate: ::RDF::URI.new('http://library.princeton.edu/terms/metadata_id'), multiple: false
  property :source_metadata, predicate: ::RDF::URI.new('http://library.princeton.edu/terms/source_metadata'), multiple: false

  # IIIF
  apply_schema IIIFBookSchema

  validate :source_metadata_identifier_or_title
  validates :access_policy, presence: { message: 'You must choose an Access Policy statement.' }
  validates :use_and_reproduction, presence: { message: 'You must provide a use statement.' }
  validates_with ViewingDirectionValidator
  validates_with ViewingHintValidator

  def apply_remote_metadata
    self.source_metadata = remote_data.source
    self.attributes = remote_data.attributes
  end

  private

    def remote_data
      @remote_data ||= remote_metadata_factory.retrieve(source_metadata_identifier)
    end

    def remote_metadata_factory
      RemoteRecord
    end

    # Validate that either the source_metadata_identifier or the title is set.
    def source_metadata_identifier_or_title
      return if source_metadata_identifier.present? || title.present?
      errors.add(:title, "You must provide a source metadata id or a title")
      errors.add(:source_metadata_identifier, "You must provide a source metadata id or a title")
    end
end
