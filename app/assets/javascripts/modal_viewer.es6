export default class ModalViewer {
  constructor() {
    $("a", this.selector).unbind("click")
    $("a", this.selector).on("click", (event) => {
      event.preventDefault()
      event.stopImmediatePropagation()
      let manifest_url = $(event.currentTarget).parents(this.selector).attr("data-modal-manifest")
      let osd_viewer = $("picture[data-openseadragon]")
      let new_source = $("<source>", { class: "osd-image", src: manifest_url, media: "openseadragon" })
      $("#viewer-modal").modal()
      osd_viewer.height($(window).height()-100)
      if(this.osd !== undefined) {
        let viewer = this.osd.data("osdViewer")
        viewer.open(manifest_url)
      } else {
        osd_viewer.html("")
        new_source.appendTo(osd_viewer)
        this.osd = osd_viewer.openseadragon()
      }
      return true
    })
  }

  get selector() {
    return "*[data-modal-manifest]"
  }
}
