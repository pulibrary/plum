# frozen_string_literal: true
class AuthorityFinder
  def self.for(property:, project:)
    return unless property.starts_with?("EphemeraFolder.") && project

    fields = EphemeraField.where name: property.to_s, ephemera_project: project
    VocabularySubauthority.new(fields.first.vocabulary.label, fields.first.vocabulary) if fields.first
  end
end
