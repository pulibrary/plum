class ScannedResourceShowPresenter < HyraxShowPresenter
  include PlumAttributes

  delegate :has?, :first, to: :solr_document
end
