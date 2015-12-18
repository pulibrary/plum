{ // Keeps everything out of global scope.
  jQuery(() => {
    window.new_sort_manager = new SortManager
  })


  class SortablePersister {
    constructor(sorter) {
      this.sorter = sorter
      this.flash = new window.Flash
      sorter.bulk_labeler.actions_element.on_save(this.persist_ordering)
    }

    get persist_ordering() {
      return (event) => {
        event.preventDefault()
        if(this.persisting == true || !this.sorter.needs_saved) {
          return
        }
        this.persisting = true
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
        this.persisting = false
      }
    }

    get persist_failed() {
      return (data) => {
        if(data && data.responseJSON && data.responseJSON.message) {
          this.flash.set("danger", data.responseJSON.message)
        } else {
          this.flash.set("danger", "Unable to save new order.")
        }
      }
    }

    get persist_success() {
      return (data) => {
        if(data.message) {
          this.flash.set("success", data.message)
          this.sorter.reset_save()
          this.sorter.bulk_labeler.check_save_button()
        }
      }
    }
  }

  class SortManager {
    constructor() {
      this.element = $("#sortable")
      this.sorting_info = {}
      this.initialize_sort()
      this.bulk_labeler = new window.BulkLabeler
      this.bulk_labeler.sorter = this
      this.initialize_persist_button()
      this.element.data("current-order", this.order)
    }

    initialize_sort() {
      this.element.sortable({handle: ".panel-heading"})
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
        this.bulk_labeler.check_save_button()
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

    get needs_saved() {
      let arr1 = this.order
      let arr2 = this.element.data("current-order")
      return JSON.stringify(arr1) != JSON.stringify(arr2)
    }

    reset_save() {
      this.element.data("current-order", this.order)
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
