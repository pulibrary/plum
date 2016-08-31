require 'vocab/f3_access'
require 'vocab/opaque_mods'
require 'vocab/pul_terms'

module CommonMetadata
  extend ActiveSupport::Concern

  included do
    before_update :check_state

    # Plum
    apply_schema PlumSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :facetable, :symbol])
    )

    # IIIF
    apply_schema IIIFBookSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
    )

    validate :source_metadata_identifier_or_title
    validates_with RightsStatementValidator
    validates_with StateValidator
    validates_with ViewingDirectionValidator
    validates_with ViewingHintValidator

    def apply_remote_metadata
      if remote_data.source
        self.source_metadata = remote_data.source.dup.try(:force_encoding, 'utf-8')
      end
      self.attributes = remote_data.attributes
      update_ezid if state == 'complete' && identifier
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
      if RemoteRecord.bibdata?(source_metadata_identifier) == 0
        JSONLDRecord::Factory.new(self.class)
      else
        RemoteRecord
      end
    end

    # Validate that either the source_metadata_identifier or the title is set.
    def source_metadata_identifier_or_title
      return if source_metadata_identifier.present? || title.present?
      errors.add(:title, "You must provide a source metadata id or a title")
      errors.add(:source_metadata_identifier, "You must provide a source metadata id or a title")
    end

    def complete_record
      if identifier
        update_ezid
      else
        self.identifier = Ezid::Identifier.mint(ezid_metadata).id
      end
    end

    def ezid_metadata
      {
        dc_publisher: 'Princeton University Library',
        dc_title: title.join('; '),
        dc_type: 'Text',
        target: ManifestBuilder::ManifestHelper.new.polymorphic_url(self)
      }
    end

    def update_ezid
      Ezid::Identifier.modify(identifier, ezid_metadata)
    end
  end
end
