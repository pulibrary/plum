class ScannedResourcePDF
  attr_reader :scanned_resource, :quality
  def initialize(scanned_resource, quality: "gray")
    @scanned_resource = scanned_resource
    @quality = quality
  end

  def pages
    manifest_builder.canvases.length + 1 # Extra page is coverpage
  end

  def render(path, force: false)
    if File.exist?(path) && !force
      File.open(path)
    else
      Renderer.new(self, path).render
    end
  end

  def manifest_builder
    @manifest_builder ||= PolymorphicManifestBuilder.new(scanned_resource)
  end
end
