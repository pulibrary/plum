{
  jQuery(() => {
    window.bulk_labeler = new BulkLabeler
  })

  class BulkLabeler {
    constructor() {
      this.element = $("*[data-action=bulk-label]")
      this.actions_element = new window.LabelerActionsManager(this.element.children(".actions"))
      $("#foliate-settings").hide()
      this.element.children("ul").selectable({stop: this.stopped_label_select})
      this.element.find("li input[type=text]").change(this.input_value_changed)
      this.element.find("li input[type=text]").on("focus", function() {
        $(this).data("current-value", $(this).val())
      })
      this.setup_buttons()
    }

    setup_buttons() {
      this.actions_element.on_apply(this.apply_labels)
      this.actions_element.on_save(this.save_labels)
      let master = this
      this.element.find("form").on("ajax:success", function() {
        let form_input = $(this)
        form_input.find("input[data-old-title]").attr("data-old-title",null)
        master.actions_element.save_button.prop("disabled", master.changed_members.length == 0)
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
          this.title_field_changing(title_field, value)
        }
      }
    }

    title_field_changing(title_field, value) {
      if(title_field.val() != value) {
        if(!title_field.attr("data-old-title")) {
          title_field.attr("data-old-title", title_field.val())
        }
        if(title_field.attr("data-old-title") == value) {
          title_field.attr("data-old-title", null)
        }
      } else {
        title_field.attr("data-old-title", null)
      }
      title_field.val(value)
      this.actions_element.save_button.prop("disabled", this.changed_members.length == 0)
    }

    get generator() {
      return this.actions_element.generator
    }

    get save_labels() {
      return (event) => {
        event.preventDefault()
        let form = null
        for(let i of this.changed_members.toArray()) {
          i = $(i)
          form = i.children("form")
          form.submit()
        }
        this.selected_elements.removeClass("ui-selected")
      }
    }

    get input_value_changed() {
      let master = this
      return function() {
        let title_field = $(this)
        let new_value = title_field.val()
        title_field.val(title_field.data("current-value"))
        master.title_field_changing(title_field, new_value)
      }
    }

    get changed_members() {
      return this.element.find("*[data-old-title]").parents("li")
    }

    get selected_elements() {
      return this.element.find("li.ui-selected")
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
}
