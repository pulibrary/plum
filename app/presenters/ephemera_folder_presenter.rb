class EphemeraFolderPresenter < HyraxShowPresenter
  self.collection_presenter_class = DynamicShowPresenter.new
  delegate :folder_number, :genre, to: :solr_document

  def renderer_for(field, _options)
    return ::BarcodeAttributeRenderer if field == :identifier
    super
  end

  def language
    super.map do |id|
      AuthorityFinder.for(property: :language, model: self).find(id)[:label]
    end
  end
end
