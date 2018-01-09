# frozen_string_literal: true
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
      dclnum = extract_dclnum(o)
      next unless dclnum && o.workflow_state == "complete"

      [dclnum, label(o), manifest_url(o), "Princeton University Library",
       o.call_number.first, o.source_metadata_identifier.first, o.identifier, nil, o.publisher.first,
       date(o), nil, nil, o.extent.first, o.rights_statement.first, original(o)]
    end
  end

  def self.date(obj)
    Date.parse(obj.date_created.first).strftime("%Y")
  rescue
    nil
  end

  def self.label(obj)
    return "Microfiche" if obj.rights_statement.first == 'http://cicognara.org/microfiche_copyright'
    "Princeton University Library"
  end

  def self.original(obj)
    obj.rights_statement.first == 'http://cicognara.org/microfiche_copyright'
  end

  def self.extract_dclnum(obj)
    xp = "//marc:datafield[@tag='024' and marc:subfield/text() = 'dclib']/marc:subfield[@code='a']"
    Nokogiri::XML(obj.source_metadata.first).xpath(xp, marc: 'http://www.loc.gov/MARC21/slim').first.text
  rescue
    nil
  end

  def self.manifest_url(obj)
    Rails.application.routes.url_helpers.send "manifest_hyrax_#{obj.model_name.singular}_url", obj
  end
end
