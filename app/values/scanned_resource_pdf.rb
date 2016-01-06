class ScannedResourcePDF
  attr_reader :scanned_resource
  def initialize(scanned_resource)
    @scanned_resource = scanned_resource
  end

  def pages
    manifest_builder.canvases.length
  end

  def render(path, force: false)
    if File.exist?(path) && !force
      File.open(path)
    else
      Renderer.new(self, path).render
    end
  end

  def manifest_builder
    @manifest_builder ||= ManifestBuilder.new(scanned_resource)
  end
end
