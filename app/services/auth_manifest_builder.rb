# Build IIIF Auth service definitions
# @see http://iiif.io/api/auth/0.9/
class AuthManifestBuilder
  def self.auth_services(login_url, logout_url)
    new(
      "@context": "http://iiif.io/api/auth/0/context.json",
      "@id": login_url,
      "label": "Login to Plum using CAS",
      "profile": "http://iiif.io/api/auth/0/login",
      "service": AuthManifestBuilder.logout_service(logout_url)
    )
  end

  def self.logout_service(logout_url)
    if logout_url
      new(
        [
          {
            "@id": logout_url,
            "label": "Logout from Plum",
            "profile": "http://iiif.io/api/auth/0/logout"
          }
        ]
      )
    else
      new(nil)
    end
  end

  attr_reader :hsh
  def initialize(hsh)
    @hsh = hsh
  end

  def apply(manifest)
    manifest['service'] = hsh if hsh.present?
  end
end
