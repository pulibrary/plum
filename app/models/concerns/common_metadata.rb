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

    validates_with RightsStatementValidator
    validates_with ViewingDirectionValidator
    validates_with ViewingHintValidator

    # We need to check if an array is equal to another array in validators, but
    # ActiveTriples doesn't return arrays, just AT::Relations.
    def read_attribute_for_validation(attribute)
      result = super
      if result.respond_to?(:each)
        result.to_a
      else
        result
      end
    end

    def identifier
      Array(super).first
    end
  end
end
