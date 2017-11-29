# frozen_string_literal: true
class ExternalFileUrlGenerator
  def self.download_url(file_set)
    pair = file_set.id.scan(/..?/).first(4).push(file_set.id)
    "#{Plum.config[:external_file_url]}/#{pair.join('/')}/#{file_set.label || file_set.id}"
  end
end
