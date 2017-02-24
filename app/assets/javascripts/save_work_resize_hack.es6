export default class SaveWorkResizeHack {
  constructor() {
    this.element = $("#savewidget")
    if(this.element.length == 0) { return }
    this.width = this.element.width()
    this.height = this.element.height()
    this.left = this.element.offset().left
    $(window).on("scroll", () => {
      if(this.element.hasClass("fixedsticky-off")) {
        this.element.width("")
        this.element.height("")
        this.element.css("left", "")
        this.width = this.element.width()
        this.height = this.element.height()
        this.left = this.element.offset().left
      } else {
        this.element.width(this.width)
        this.element.height(this.height)
        this.element.offset({"left": this.left})
      }
    })
    $(window).on("resize", () => {
      if(this.element.hasClass("fixedsticky-off")) {
        this.width = this.element.width()
        this.height = this.element.height()
        this.left = this.element.offset().left
      }
    })
  }
}
