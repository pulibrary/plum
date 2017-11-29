# frozen_string_literal: true
module CollectionIndexing
  extend ActiveSupport::Concern
  included do
    self.indexer = ::WorkIndexer
  end
end
