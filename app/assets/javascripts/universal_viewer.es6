export default class UniversalViewer {
  constructor() {
    this.addFullscreenEventListeners()
  }

  addFullscreenEventListeners() {
    if (document.addEventListener) {
      document.addEventListener("webkitfullscreenchange", () => this.exitHandler(this), false)
      document.addEventListener("mozfullscreenchange", () => this.exitHandler(this), false)
      document.addEventListener("fullscreenchange", () => this.exitHandler(this), false)
      document.addEventListener("MSFullscreenChange", () => this.exitHandler(this), false)
    }
  }

  /** 
  * Asynchronously removes styling from the universal viewer iframe after a timeout.
  * This is a workaround for issues related to exiting fullscreen mode by pressing the
  * escape key.
  */
  exitHandler() {
    let fullscreen = document.webkitIsFullScreen || document.mozFullScreen || document.msFullscreenElement

    if (fullscreen !== true) {
      this.sleep(200).then(() => {
        let frame = document.getElementsByTagName("iframe")[0]
        frame.style.top = null
        frame.style.left = null
      })
    }
  }

  sleep(time) {
    return new Promise((resolve) => setTimeout(resolve, time))
  }
}
