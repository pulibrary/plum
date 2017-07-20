class EphemeraFolderPresenter < HyraxShowPresenter
  include PlumAttributes
  self.collection_presenter_class = DynamicShowPresenter.new
  delegate :barcode, :box_id,
           :date_modified,
           :date_uploaded,
           :description,
           :ephemera_project_id,
           :ephemera_project_name,
           :folder_number,
           :ephemera_height,
           :page_count,
           :sort_title,
           :ephemera_width,
           to: :solr_document

  def member_presenter_factory
    ::EfficientMemberPresenterFactory.new(solr_document, current_ability, request)
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

  def subject
    Array.wrap(solr_document.subject).map do |id|
      authority_for(:subject).find(id)[:label]
    end
  end

  def subject_categories
    Array.wrap(solr_document.subject).map do |id|
      subject = VocabularyTerm.find(id)
      subject.vocabulary.label if subject.vocabulary
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
        fields.merge!(
          '@type': 'pcdm:Object', alternative: alternative, creator: creator, contributor: contributor,
          publisher: publisher, barcode: barcode, label: "Folder #{folder_number}",
          is_part_of: ephemera_project_name, coverage: geo_subject, dcterms_type: lookup_objects(:genre),
          origin_place: lookup_objects(:geographic_origin), language: lookup_objects(:language),
          subject: lookup_objects(:subject), category: subject_categories, description: description,
          source: to_uri(source), related_url: to_uri(related_url), height: ephemera_height,
          width: ephemera_width, sort_title: sort_title, page_count: Array.wrap(page_count).first,
          created: date_uploaded, modified: date_modified, folder_number: folder_number
        )
        fields[:identifier] = identifier unless identifier.blank?
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
      obj = { '@id': Rails.application.routes.url_helpers.vocabulary_term_url(id), '@type': 'skos:Concept', pref_label: term.label }
      obj[:exact_match] = to_uri(term.uri) if term.uri.present?
      obj
    rescue
      Rails.logger.warn "Error looking up #{type} #{id}"
      id
    end

    def to_uri(value)
      { "@id": Array.wrap(value).first }
    end

    def collection_objects
      return if member_of_collection_ids.blank?
      member_of_collection_ids.zip(collection).map do |arr|
        (arr.first == box_id) ? box_info : { '@id': col_url(arr.first), '@type': 'pcdm:Collection', title: arr.last }
      end
    end

    def box_info
      box = EphemeraBox.find(box_id)
      {
        '@id': Rails.application.routes.url_helpers.hyrax_ephemera_box_path(box), '@type': 'pcdm:Collection',
        barcode: box.barcode.first, label: "Box #{box.box_number.first}", holding_location: 'rcpxr',
        box_number: box.box_number.first
      }
    end
end
