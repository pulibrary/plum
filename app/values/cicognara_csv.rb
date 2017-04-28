class CicognaraCSV
  def self.headers
    ['digital_cico_number', 'label', 'manifest', 'contributing_library',
     'owner_call_number', 'owner_system_number', 'other_number',
     'version_edition_statement', 'version_publication_statement', 'version_publication_date',
     'additional_responsibility', 'provenance', 'physical_characteristics', 'rights', 'based_on_original']
  end

  def self.values(collection)
    collection.member_objects.map do |o|
      # parse digital_cico_number from marc
      xp = "//marc:datafield[@tag='024' and marc:subfield/text() = 'dclib']/marc:subfield[@code='a']"
      dclnum = Nokogiri::XML(o.source_metadata.first).xpath(xp, marc: 'http://www.loc.gov/MARC21/slim').first.text

      [dclnum, "Plum", manifest_url(o), "Princeton University Library",
       o.call_number.first, o.source_metadata_identifier.first, o.identifier,
       nil, o.publisher.first, Date.parse(o.date_created.first).strftime("%Y"),
       nil, nil, o.extent.first, o.rights_statement.first, false]
    end
  end

  def self.manifest_url(obj)
    Rails.application.routes.url_helpers.send "manifest_hyrax_#{obj.model_name.singular}_url", obj
  end
end
