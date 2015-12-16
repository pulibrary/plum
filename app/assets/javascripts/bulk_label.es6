/* exported BulkLabeler */
class BulkLabeler {
  constructor() {
    this.element = $("*[data-action=bulk-label]")
    this.actions_element = new window.LabelerActionsManager(this.element.find(".actions"))
    $("#foliate-settings").hide()
    $("#order-grid").selectable(
      {
        filter: ".panel",
        stop: this.stopped_label_select,
        selecting: window.shift_enabled_selecting(),
        cancel: "a,input,option,label,button,.ignore-select"
      }
    )
    this.element.find("li input[type=text]").change(this.input_value_changed)
    this.element.find("li input[type=text]").on("focus", function() {
      $(this).data("current-value", $(this).val())
    })
    this.track_radio_buttons()
    this.setup_buttons()
    this.flash = new window.Flash
  }

  initialize_radio_buttons() {
    // Simple form doesn't add unique IDs to the form IDs, so need javascript to
    // fix them up.
    this.element.find("span.radio").each((index, element) => {
      element = $(element)
      let input = $("input[type=radio]", element)
      let label = $("label", element)
      let id = element.parents("li[data-reorder-id]").first().attr("data-reorder-id")
      let current_id = input.attr("id")
      input.attr("id", `${current_id}_${id}`)
      label.attr("for", input.attr("id"))
    })
    this.element.find("li input[type=radio]:checked").each(function(id, element) {
      element = $(element)
      let parent = element.parents("div").first()
      parent.attr("data-first-value", element.val())
    })
  }
  track_radio_buttons() {
    let master = this
    this.initialize_radio_buttons()
    this.element.find("li input[type=radio]").change(function() {
      let parent = $(this).parents("div").first()
      if(parent.attr("data-first-value") != $(this).val()) {
        parent.attr("data-old-value", $(this).val())
      } else {
        parent.attr("data-old-value", null)
      }
      master.check_save_button()
    })
  }

  setup_buttons() {
    this.actions_element.on_apply(this.apply_labels)
    this.actions_element.on_save(this.save_labels)
    let master = this
    this.element.find("form").on("ajax:success", function() {
      let form_input = $(this)
      window.form_input = form_input
      form_input.find("*[data-old-value]").attr("data-old-value",null)
      master.initialize_radio_buttons()
      master.check_save_button()
    })
  }


  get apply_labels() {
    return (event) => {
      event.preventDefault()
      let generator = this.generator
      let value = null
      let title_field = null
      for(let i of this.selected_elements.toArray()) {
        i = $(i)
        value = generator.next().value
        title_field = i.find("input[name='file_set[title][]']")
        this.field_changing(title_field, value)
      }
    }
  }

  field_changing(field, value) {
    if(field.val() != value) {
      if(!field.attr("data-old-value")) {
        field.attr("data-old-value", field.val())
      }
      if(field.attr("data-old-value") == value) {
        field.attr("data-old-value", null)
      }
    } else {
      field.attr("data-old-value", null)
    }
    field.val(value)
    this.check_save_button()
  }

  get generator() {
    return this.actions_element.generator
  }

  get save_labels() {
    return (event) => {
      event.preventDefault()
      this.changed_members.find("form").submit()
      this.selected_elements.removeClass("ui-selected")
    }
  }

  get input_value_changed() {
    let master = this
    return function() {
      let field = $(this)
      let new_value = field.val()
      field.val(field.data("current-value"))
      master.field_changing(field, new_value)
    }
  }

  get needs_saved() {
    return this.changed_members.length != 0 || this.sorter.needs_saved
  }

  check_save_button() {
    this.actions_element.save_button.prop("disabled", !this.needs_saved)
  }

  get changed_members() {
    return this.element.find("*[data-old-value]").parents("li")
  }

  get selected_elements() {
    return this.element.find("li .panel.ui-selected")
  }

  get stopped_label_select() {
    return () => {
      let selected_count = this.selected_elements.length
      if(selected_count > 0) {
        this.actions_element.apply_button.enable()
        this.actions_element.inputs.prop("disabled", false)
      } else {
        this.actions_element.apply_button.disable()
        this.actions_element.inputs.prop("disabled", true)
      }
    }
  }
}
