{
  jQuery(() => {
    window.modal_viewer = new ModalViewer
  })
  class ModalViewer {
    constructor() {
      this.element = $(this.selector)
      $("a", this.element).unbind("click")
      $("body").on("click", this.selector, function(event) {
        event.stopPropagation()
        event.preventDefault()
        let manifest_url = $(this).attr("data-modal-manifest")
        let osd_viewer = $("picture[data-openseadragon]")
        let new_source = $("<source>", { class: "osd-image", src: manifest_url, media: "openseadragon" })
        $("#viewer-modal").modal()
        osd_viewer.height($(window).height()-100)
        osd_viewer.html("")
        new_source.appendTo(osd_viewer)
        osd_viewer.openseadragon()
        return true
      })
    }

    get selector() {
      return "*[data-modal-manifest]"
    }
  }
}
