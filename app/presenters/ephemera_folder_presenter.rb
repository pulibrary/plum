class EphemeraFolderPresenter < HyraxShowPresenter
  self.collection_presenter_class = DynamicShowPresenter.new
  delegate :folder_number, to: :solr_document

  def renderer_for(field, _options)
    return ::BarcodeAttributeRenderer if field == :identifier
    super
  end

  def language
    Array.wrap(super).map do |id|
      authority_for(:language).find(id)[:label]
    end
  end

  def genre
    Array.wrap(solr_document.genre).map do |id|
      authority_for(:genre).find(id)[:label]
    end
  end

  def geographic_origin
    Array.wrap(solr_document.geographic_origin).map do |id|
      authority_for(:geographic_origin).find(id)[:label]
    end
  end

  def geo_subject
    Array.wrap(solr_document.geo_subject).map do |id|
      authority_for(:geo_subject).find(id)[:label]
    end
  end

  def authority_for(property)
    AuthorityFinder.for(property: property, model: self) || NullAuthority
  end

  class NullAuthority
    def self.find(id)
      { id: id, label: id }
    end
  end
end
