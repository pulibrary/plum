require 'vocab/f3_access'
require 'vocab/opaque_mods'
require 'vocab/pul_terms'

module GeoMetadata
  extend ActiveSupport::Concern

  included do
    apply_schema GeoSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:symbol, :stored_searchable, :facetable])
    )

    validates_with RightsStatementValidator
  end
end
