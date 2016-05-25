module LanguageService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('iso639')

  def self.label(id)
    authority.find(id).fetch('term', id)
  end
end
