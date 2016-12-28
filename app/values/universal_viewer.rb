class UniversalViewer
  include Singleton
  class << self
    def script_tag
      @script_tag ||= instance.script_tag
    end
  end

  def script_tag
    "<script type=\"text/javascript\" id=\"embedUV\" src=\"#{viewer_link}\"></script>".html_safe
  end

  def viewer_link
    "#{Rails.application.config.relative_url_root}/#{viewer_root}/uv-#{viewer_version}/lib/embed.js"
  end

  def viewer_root
    "bower_includes/universalviewer/dist"
  end

  def viewer_version
    Dir.glob(absolute_root.join("*")).map do |x|
      Pathname.new(x)
    end.select(&:directory?)
      .map(&:basename)
      .map(&:to_s).first.split("-").last
  end

  private

    def absolute_root
      Rails.root.join("public", viewer_root)
    end
end
