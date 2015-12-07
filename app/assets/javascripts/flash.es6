/* exported Flash */
class Flash {
  constructor() {
    this.element = $("*[data-reorder-action='flash']")
    this.element.children(".close").click(
      () => {
        this.element.hide()
      }
    )
  }
  reset_type() {
    this.element.removeClass("alert-success")
    this.element.removeClass("alert-danger")
  }
  set(type, message) {
    this.reset_type()
    this.element.addClass(`alert-${type}`)
    this.element.children(".text").text(message)
    this.element.show()
    this.element.removeClass("hidden")
  }
}
