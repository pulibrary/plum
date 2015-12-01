require 'vocab/f3_access'
require 'vocab/opaque_mods'
require 'vocab/pul_terms'

module CommonMetadata
  extend ActiveSupport::Concern

  included do
    before_update :check_completion

    property :sort_title, predicate: ::OpaqueMods.titleForSort, multiple: false
    property :portion_note, predicate: ::RDF::SKOS.scopeNote, multiple: false
    property :description, predicate: ::RDF::DC.abstract, multiple: false
    property :identifier, predicate: ::RDF::DC.identifier, multiple: false
    property :access_policy, predicate: ::RDF::DC.accessRights, multiple: false
    property :use_and_reproduction, predicate: ::RDF::DC.rights, multiple: false
    property :source_metadata_identifier, predicate: ::PULTerms.metadata_id, multiple: false
    property :source_metadata, predicate: ::PULTerms.source_metadata, multiple: false
    property :state, predicate: ::F3Access.objState, multiple: false do |index|
      index.as :stored_searchable, :facetable
    end

    # IIIF
    apply_schema IIIFBookSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
    )

    validate :source_metadata_identifier_or_title
    validates :access_policy, presence: { message: 'You must choose an Access Policy statement.' }
    validates :use_and_reproduction, presence: { message: 'You must provide a use statement.' }
    validates_with StateValidator
    validates_with ViewingDirectionValidator
    validates_with ViewingHintValidator

    def apply_remote_metadata
      self.source_metadata = remote_data.source
      self.attributes = remote_data.attributes
    end

    def check_completion
      complete_record if self.state_changed? && state == 'complete'
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

    def complete_record
      self.identifier = Ezid::Identifier.create.id unless identifier
      ReviewerMailer.completion_email(id).deliver_later
    end
  end
end
