# frozen_string_literal: true
module CollectionTitleIndexing
  extend ActiveSupport::Concern
  included do
    self.indexer = ::CollectionIndexer
  end
end
