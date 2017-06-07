class AuthorityFinder
  def self.for(property:, project:)
    return unless property.starts_with?("EphemeraFolder.") && project
    begin
      fields = EphemeraField.where name: "#{property}", ephemera_project: project
      Qa::Authorities::Local.subauthority_for(fields.first.vocabulary.label) if fields.first
    rescue Qa::InvalidSubAuthority
      Rails.logger.debug("Non-existent sub-authority requested for property #{property}")
      nil
    end
  end
end
