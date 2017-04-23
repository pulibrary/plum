class FilePath
  attr_reader :uri
  def initialize(uri)
    @uri = uri.to_s
  end

  def clean
    ::URI.unescape(::URI.split(::URI.escape(uri)).compact.last)
  end
end
