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

  private

    def local_fields
      super.tap do |fields|
        fields['@type'] = 'pcdm:Object'
        fields[:alternative] = alternative
        fields[:creator] = creator
        fields[:contributor] = contributor
        fields[:publisher] = publisher
        fields[:identifier] = [identifier.first, barcode].reject(&:blank?)
        fields[:label] = "Folder #{folder_number}"
        fields[:is_part_of] = ephemera_project_name
        fields[:coverage] = geo_subject
        fields[:dcterms_type] = lookup_objects(:genre)
        fields[:origin_place] = lookup_objects(:geographic_origin)
        fields[:language] = lookup_objects(:language)
        fields[:subject] = lookup_objects(:subject)
      end
    end

    def lookup_objects(type)
      Array.wrap(solr_document.send(type)).map do |id|
        convert_to_object(id)
      end
    end

    def convert_to_object(id)
      return id unless id.match(/^\d+/)
      term = VocabularyTerm.find(id)
      obj = { '@id': Rails.application.routes.url_helpers.vocabulary_term_url(id), pref_label: term.label }
      obj[:exact_match] = { '@id': term.uri } if term.uri.present?
      obj
    rescue
      Rails.logger.warn "Error looking up #{type} #{id}"
      id
    end
end
