jQuery ->
  new ManifestViewBuilder($("*[data-manifest]"))
class ManifestViewBuilder
  constructor: (element) ->
    @element = $(element)
    $.getJSON(this.manifest_url(), this.build_viewer)
  manifest_url: ->
    @element.data("manifest")
  build_viewer: (manifest) =>
    manifest = new Manifest(manifest)
    window.manifest = manifest
    data = Array()
    image_info = {}
    image_info.iiifServer = manifest.primary_image_server
    image_info.images = manifest.images
    @element.iiifOsdViewer(data: [
      image_info
    ])
class Manifest
  constructor: (manifest) ->
    @manifest = manifest
    @images = this.getImages()
    @primary_image_server = @images[0].image_server
  getImages: ->
    $.map(@manifest.sequences[0].canvases, this.buildCanvas)
  buildCanvas: (canvas) ->
    new Canvas(canvas)
class Canvas
  constructor: (canvas) ->
    @canvas = canvas
    @height = @canvas.height
    @width = @canvas.width
    @label = @canvas.label
    @image_server = this.getImageServer()
    @image_id = this.getImageID()
    @id = @image_id
  getImageURL: ->
    @canvas.images[0].resource.service['@id']
  getImageServer: ->
    image_server = this.getImageURL().split("/")
    image_server.pop()
    image_server.join("/")
  getImageID: ->
    this.getImageURL().split("/").pop()
