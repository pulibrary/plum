class LocalFileUrlGenerator
  def self.download_url(file_set)
    Rails.application.routes.url_helpers.download_url file_set
  end
end
