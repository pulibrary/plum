# Build IIIF Auth service definitions
# @see http://iiif.io/api/auth/0.9/
class AuthManifestBuilder
  def self.auth_services(login_url, logout_url)
    {
      "@context": "http://iiif.io/api/auth/0/context.json",
      "@id": login_url,
      "label": "Login to Plum using CAS",
      "profile": "http://iiif.io/api/auth/0/login",
      "service": AuthManifestBuilder.logout_service(logout_url)
    }
  end

  def self.logout_service(logout_url)
    return [] unless logout_url
    [{
      "@id": logout_url,
      "label": "Logout from Plum",
      "profile": "http://iiif.io/api/auth/0/logout"
    }]
  end
end
