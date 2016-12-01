class ExternalFileUrlGenerator
  def self.download_url(file_set)
    pair = file_set.id.scan(/..?/).first(4) # TODO: add .push(id) when CC is updated
    "#{Plum.config[:external_file_url]}/#{pair.join('/')}/#{file_set.label || file_set.id}"
  end
end
