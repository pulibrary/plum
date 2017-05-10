class WorkIndexer < Hyrax::WorkIndexer
  # TODO: Refactor complexity here.
  def generate_solr_document
    super.tap do |solr_doc|
      object.member_of_collections.each do |col|
        key = Solrizer.solr_name('member_of_collection_slugs', :symbol)
        solr_doc[key] ||= []
        solr_doc[key] << col.try(:exhibit_id)
        solr_doc[key].compact!
      end
      (PlumSchema.display_fields + [:title]).each do |field|
        objects = object.get_values(field, literal: true)
        statements = objects.map do |obj|
          ::RDF::Statement.from([object.rdf_subject, ::RDF::URI(""), obj])
        end
        output = JSON::LD::API.fromRdf(statements)
        next unless output.length > 0
        output = output[0][""]
        output.map! do |object|
          if object.is_a?(Hash) && object["@value"] && object.keys.length == 1
            object["@value"]
          else
            object.to_json
          end
        end
        titles = solr_doc[Solrizer.solr_name('title', :stored_searchable)] || []
        solr_doc['title_ssort'] = titles.to_sentence
        solr_doc[Solrizer.solr_name("#{field}_literals", :symbol)] = output
      end
      solr_doc[Solrizer.solr_name("identifier", :symbol)] = object.identifier
      [:geo_subject, :geographic_origin, :genre, :subject].each do |property|
        next unless object.respond_to?(property)
        solr_doc[Solrizer.solr_name(property.to_s, :facetable)] = object.send(property).map do |code|
          authority = AuthorityFinder.for(property: property, model: object)
          authority.find(code)[:label] if authority
        end.compact
      end
      subject_authority = AuthorityFinder.for(property: :subject, model: object)
      if subject_authority
        solr_doc[Solrizer.solr_name("category", :facetable)] = object.send(:subject).map do |code|
          subject_authority.find(code)[:vocabulary] if subject_authority
        end.compact
      end
      solr_doc[Solrizer.solr_name("language", :facetable)] = object.language.map do |code|
        AuthorityFinder.for(property: :language, model: object).try(:find, code).try(:[], :label) || LanguageService.label(code)
      end

      suppress solr_doc, 'source_metadata'
    end
  end

  def suppress(solr_doc, field)
    [:symbol, :stored_searchable, :facetable].each do |type|
      solr_doc.delete(Solrizer.solr_name(field, type))
    end
  end
end
