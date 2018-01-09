# frozen_string_literal: true
class WorkIndexer < Hyrax::WorkIndexer
  # TODO: Refactor complexity here.
  def generate_solr_document
    super.tap do |solr_doc|
      object.member_of_collections.each do |col|
        key = Solrizer.solr_name('member_of_collection_slugs', :symbol)
        solr_doc[key] ||= []
        solr_doc[key] << col.try(:exhibit_id)
        solr_doc[key].compact!

        next unless col.is_a?(EphemeraBox)
        solr_doc[Solrizer.solr_name('box_id', :symbol)] = col.id

        next unless col.ephemera_project.first
        solr_doc[Solrizer.solr_name("ephemera_project_id", :symbol)] = col.ephemera_project.first
        solr_doc[Solrizer.solr_name("ephemera_project_name", :symbol)] = EphemeraProject.find(col.ephemera_project.first).name
      end
      (PlumSchema.display_fields + [:title]).each do |field|
        objects = object.get_values(field, literal: true)
        statements = objects.map do |obj|
          ::RDF::Statement.from([object.rdf_subject, ::RDF::URI(""), obj])
        end
        output = JSON::LD::API.fromRdf(statements)
        next if output.empty?
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
      solr_doc[Solrizer.solr_name("barcode", :symbol)] = object.try(:barcode)
      if object.respond_to?(:ephemera_project) && object.ephemera_project.first
        solr_doc[Solrizer.solr_name("ephemera_project_id", :symbol)] = object.ephemera_project.first
        solr_doc[Solrizer.solr_name("ephemera_project_name", :symbol)] = EphemeraProject.find(object.ephemera_project.first).name
      end
      [:geo_subject, :geographic_origin, :genre, :subject].each do |property|
        next unless object.respond_to?(property)
        solr_doc[Solrizer.solr_name(property.to_s, :facetable)] = object.send(property).map do |code|
          authority = AuthorityFinder.for(property: "#{object.model_name}.#{property}", project: object.try(:project))
          authority&.find(code)[:label]
        end.compact
      end
      subject_authority = AuthorityFinder.for(property: "#{object.model_name}.subject", project: object.try(:project))
      if subject_authority
        solr_doc[Solrizer.solr_name("category", :facetable)] = object.send(:subject).map do |code|
          subject_authority&.find(code)[:vocabulary]
        end.compact
      end
      solr_doc[Solrizer.solr_name("language", :facetable)] = object.language.map do |code|
        AuthorityFinder.for(property: "#{object.model_name}.language", project: object.try(:project)).try(:find, code).try(:[], :label) || LanguageService.label(code)
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
