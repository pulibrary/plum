class ScannedResourcePDF
  attr_reader :scanned_resource
  def initialize(scanned_resource)
    @scanned_resource = scanned_resource
  end

  def pages
    manifest_builder.canvases.length
  end

  def render(path)
    Renderer.new(self, path).render
  end

  def manifest_builder
    @manifest_builder ||= ManifestBuilder.new(scanned_resource)
  end
end
