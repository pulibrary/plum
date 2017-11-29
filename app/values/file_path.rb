# frozen_string_literal: true
class FilePath
  attr_reader :uri
  def initialize(uri)
    @uri = uri.to_s
  end

  def clean
    ::URI.split(uri).compact.last
  end
end
