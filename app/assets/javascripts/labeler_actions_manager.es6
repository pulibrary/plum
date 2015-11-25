/* exported LabelerActionsManager */
class LabelerActionsManager {
  constructor(element) {
    this.element = element
    this.apply_button.disable()
    this.save_button.disable()
    this.inputs.prop("disabled", true)
    this.element.find("input[name=method]").change(function() {
      var element = $(this)
      if(element.val() == "foliate") {
        $("#foliate-settings").show()
      } else {
        $("#foliate-settings").hide()
      }
    })
  }

  on_apply(func) {
    return this.apply_button.click(func)
  }

  on_save(func) {
    return this.save_button.click(func)
  }

  get generator() {
    return window.lg.pageLabelGenerator(this.first,
                                        this.method,
                                        this.frontLabel,
                                        this.backLabel,
                                        this.startWith,
                                        this.unitLabel,
                                        this.bracket)
  }

  get first() {
    return parseInt(this.element.find("input[name=start_with]").val())
  }

  get method() {
    return this.element.find("input[name=method]:checked").val()
  }

  get frontLabel() {
    let front_label_element = this.element.find("input[name=front_label]")
    if(front_label_element.is(":visible")) {
      return front_label_element.val()
    } else {
      return ""
    }
  }

  get backLabel() {
    let back_label_element = this.element.find("input[name=back_label]")
    if(back_label_element.is(":visible")) {
      return back_label_element.val()
    } else {
      return ""
    }
  }

  get startWith() {
    return this.element.find("input[name=foliate_start_with]:checked").val()
  }

  get unitLabel() {
    return this.element.find("input[name=unit_label]").val()
  }

  get bracket() {
    return this.element.find("input[name=bracket]").prop("checked")
  }

  get apply_button() {
    return new ActionsButton(this.element.find("*[data-action=apply-labels]"))
  }

  get save_button() {
    return new ActionsButton(this.element.find("*[data-action=save-labels]"))
  }

  get inputs() {
    return this.element.find("input")
  }
}

class ActionsButton {
  constructor(element) {
    this.element = element
  }

  disable() {
    this.element.prop("disabled", true)
  }

  enable() {
    this.element.prop("disabled", false)
  }

  click(func) {
    return this.element.click(func)
  }

  prop(property, value) {
    return this.element.prop(property, value)
  }
}
