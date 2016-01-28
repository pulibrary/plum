require 'vocab/f3_access'
require 'vocab/opaque_mods'
require 'vocab/pul_terms'

module CommonMetadata
  extend ActiveSupport::Concern

  included do
    before_update :check_state

    property :sort_title, predicate: ::OpaqueMods.titleForSort, multiple: false
    property :portion_note, predicate: ::RDF::Vocab::SKOS.scopeNote, multiple: false
    property :description, predicate: ::RDF::DC.abstract, multiple: false
    property :identifier, predicate: ::RDF::DC.identifier, multiple: false
    property :rights_statement, predicate: ::RDF::Vocab::EDM.rights, multiple: false do |index|
      index.as :stored_searchable, :facetable
    end
    property :rights_note, predicate: ::RDF::Vocab::DC11.rights, multiple: false do |index|
      index.as :stored_searchable
    end
    property :access_policy, predicate: ::RDF::DC.accessRights, multiple: false
    property :source_metadata_identifier, predicate: ::PULTerms.metadata_id, multiple: false do |index|
      index.as :stored_searchable, :symbol
    end
    property :source_metadata, predicate: ::PULTerms.source_metadata, multiple: false
    property :state, predicate: ::F3Access.objState, multiple: false do |index|
      index.as :stored_searchable, :facetable
    end
    property :workflow_note, predicate: ::RDF::Vocab::MODS.note do |index|
      index.as :stored_searchable, :symbol
    end
    property :holding_location, predicate: ::RDF::Vocab::Bibframe.heldBy, multiple: false do |index|
      index.as :stored_searchable
    end

    # IIIF
    apply_schema IIIFBookSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
    )

    validate :source_metadata_identifier_or_title
    validates :access_policy, presence: { message: 'You must choose an Access Policy statement.' }
    validates_with RightsStatementValidator
    validates_with StateValidator
    validates_with ViewingDirectionValidator
    validates_with ViewingHintValidator

    def apply_remote_metadata
      self.source_metadata = remote_data.source.try(:force_encoding, 'utf-8')
      self.attributes = remote_data.attributes
    end

    def check_state
      return unless state_changed?
      complete_record if state == 'complete'
      ReviewerMailer.notify(id, state).deliver_later
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
    end
  end
end
