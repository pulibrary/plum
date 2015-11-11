{ // Keeps everything out of global scope.
  jQuery(() => {
    window.new_sort_manager = new SortManager
    // Auto-submit reorder forms.
    $("*[data-reorder-id] input").change(
      function() {
        const parent_form = $(this).parents("form")
        parent_form.submit()
      }
    )
  })

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

  class SortablePersister {
    constructor(sorter) {
      this.element = $("*[data-reorder-action='persist']")
      this.element.click(this.persist_ordering)
      this.sorter = sorter
      this.flash = new Flash
    }

    get persist_ordering() {
      return (event) => {
        event.preventDefault()
        if(this.persisting == true) {
          return
        }
        this.persisting = true
        this.begin_save()
        console.log(this.sorter.id)
        $.post(`/concern/scanned_resources/${this.sorter.id}/reorder.json`,
               {order: this.sorter.order}
              )
              .done(this.persist_success)
              .always(this.persist_finished)
              .fail(this.persist_failed)
      }
    }

    get persist_finished() {
      return () => {
        this.element.text(this.element.data("old-text"))
        this.persisting = false
      }
    }

    get persist_failed() {
      return (data, message) => {
        if(data && data.message) {
          this.flash.set('danger', data.message)
        } else {
          this.flash.set('danger', "Unable to save new order.")
        }
        this.disable()
      }
    }

    get persist_success() {
      return (data) => {
        if(data.message) {
          this.flash.set('success', data.message)
        }
      }
    }

    activate() {
      this.element.removeClass("disabled")
    }

    disable() {
      this.element.addClass("disabled")
    }

    begin_save() {
      this.element.addClass("disabled")
      this.element.data("old-text", this.element.text())
      this.element.text("Saving...")
    }
  }

  class SortManager {
    constructor() {
      this.element = $("#sortable")
      this.sorting_info = {}
      this.initialize_sort()
      this.initialize_persist_button()
    }

    initialize_sort() {
      this.element.sortable()
      this.element.disableSelection()
      this.element.on("sortstop", this.stopped_sorting)
      this.element.on("sortstart", this.started_sorting)
    }

    initialize_persist_button() {
      this.sortable_persister = new SortablePersister(this)
    }

    get_sort_position(item) {
      return this.element.children().index(item)
    }

    get stopped_sorting() {
      return (event, ui) => {
        this.sorting_info.end = this.get_sort_position($(ui.item))
        if(this.sorting_info.end == this.sorting_info.start) {
          return
        }
        this.sortable_persister.activate()
      }
    }

    get started_sorting() {
      return (event, ui) => {
        this.sorting_element = $(ui.item)
        this.sorting_info.start = this.get_sort_position(ui.item)
      }
    }

    get id() {
      return this.element.data("id")
    }

    get order() {
      return $("*[data-reorder-id]").map(
        function() {
          return $(this).data("reorder-id")
        }
      ).toArray()
    }
  }
}
