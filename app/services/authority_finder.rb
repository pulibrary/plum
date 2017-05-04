class AuthorityFinder
  def self.for(property:, model:)
    return unless model.model_name.singular == "ephemera_folder"
    begin
      case property
      when :language
        Qa::Authorities::Local.subauthority_for('languages')
      end
    rescue Qa::InvalidSubAuthority
      Rails.logger.debug("Non-existent sub-authority requested for property #{property}")
      nil
    end
  end
end
