require 'vocab/f3_access'
require 'vocab/opaque_mods'
require 'vocab/pul_terms'

module CommonMetadata
  extend ActiveSupport::Concern

  included do
    # Plum
    apply_schema PlumSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:symbol, :stored_searchable, :facetable])
    )

    # IIIF
    apply_schema IIIFBookSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
    )

    validate :source_metadata_identifier_or_title
    validates_with RightsStatementValidator
    validates_with ViewingDirectionValidator
    validates_with ViewingHintValidator

    def apply_remote_metadata
      if remote_data.source
        self.source_metadata = remote_data.source.dup.try(:force_encoding, 'utf-8')
      end
      self.attributes = remote_data.attributes
      update_ezid if state == 'complete' && identifier
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
  end
end
