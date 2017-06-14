class EphemeraFolderPresenter < HyraxShowPresenter
  include PlumAttributes
  self.collection_presenter_class = DynamicShowPresenter.new
  delegate :barcode, :folder_number, :box_id, :ephemera_project_id, :ephemera_project_name, to: :solr_document

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

  def subject
    Array.wrap(solr_document.subject).map do |id|
      authority_for(:subject).find(id)[:label]
    end
  end

  def authority_for(property)
    AuthorityFinder.for(property: "EphemeraFolder.#{property}", project: ephemera_project_id) || NullAuthority
  end

  class NullAuthority
    def self.find(id)
      { id: id, label: id }
    end
  end
end
