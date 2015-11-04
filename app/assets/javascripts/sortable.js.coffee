jQuery ->
  window.sort_manager = new SortManager
class Flash
  constructor: ->
    @element = $("*[data-reorder-action='flash']")
    @element.children(".close").click =>
      @element.hide()
  reset_type: ->
    @element.removeClass("alert-success")
    @element.removeClass("alert-danger")
  set: (type, message) ->
    this.reset_type()
    @element.addClass("alert-#{type}")
    @element.children(".text").text(message)
    @element.show()
    @element.removeClass("hidden")
class SortManager
  constructor: ->
    @element = $("#sortable")
    @sorting_info = {}
    @sorting_actions = []
    this.initialize_sort()
    this.initialize_persist_button()
    this.initialize_flash()
  initialize_sort: ->
    @element.sortable()
    @element.disableSelection()
    @element.on("sortstop", this.stopped_sorting)
    @element.on("sortstart", this.started_sorting)
  initialize_persist_button: ->
    @persist_button = $("*[data-reorder-action='persist']")
    @persist_button.click(this.persist_ordering)
  initialize_flash: ->
    @flash = new Flash
  started_sorting: (event, ui) =>
    @sorting_element = $(ui.item)
    @sorting_info.start = this.get_sort_position(ui.item)
    window.sorting_element = $(ui.item)
  stopped_sorting: (event, ui) =>
    @sorting_info.end = this.get_sort_position($(ui.item))
    return if @sorting_info.end == @sorting_info.start
    @persist_button.removeClass("disabled")
  get_sort_position: (item) ->
    @element.children().index(item)
  get_order: ->
    $("*[data-reorder-id]").map(->
      $(this).data("reorder-id")
    ).toArray()
  persist_ordering: (event) =>
    event.preventDefault()
    return if @persisting == true
    @persisting = true
    console.log("Persisting Reordering")
    @persist_button.addClass("disabled")
    @persist_button.data("old-text", @persist_button.text())
    @persist_button.text("Saving...")
    order = this.get_order()
    $.post("/concern/scanned_resources/#{@element.data("id")}/reorder.json", {order: order}).done( (data) =>
      @sorting_actions = []
      if data.message?
        @flash.set('success', data.message)
    ).always( =>
      @persist_button.text(@persist_button.data("old-text"))
      @persisting = false
    ).fail( (data, message) =>
      if data?.message?
        @flash.set('danger', data.message)
      else
        @flash.set('danger', "Unable to save new order.")
      @persist_button.removeClass("disabled")
    )
