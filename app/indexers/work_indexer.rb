class WorkIndexer < Hyrax::WorkIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      object.member_of_collections.each do |col|
        solr_doc[Solrizer.solr_name('member_of_collection_slugs', :symbol)] = col.exhibit_id
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
      solr_doc[Solrizer.solr_name("language", :facetable)] = object.language.map do |code|
        LanguageService.label(code)
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
