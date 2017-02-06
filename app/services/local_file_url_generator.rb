class LocalFileUrlGenerator
  def self.download_url(file_set)
    ManifestBuilder::HyraxManifestHelper.new.download_url(file_set)
  end
end
