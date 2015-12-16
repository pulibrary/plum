jQuery(() => {
  function new_node() {
    return $("<li>", { class: "expanded" }).append(
      $("<div>").append(
        $("<div>", { class: "panel panel-default" }).append(
          $("<div>", { class: "panel-heading" }).append(
            $("<div>", { class: "row" }).append(
              $("<div>", { class: "title" }).append(
                $("<span>", { class: "move glyphicon glyphicon-move" })).append(
                $("<span>", { class: "glyphicon expand-collapse" })).append(
                $("<input>", { type: "text", name: "label", id: "label" }))).append(
              $("<div>", { class: "toolbar" }).append(
                $("<a>", { href: "", "data-action": "remove-list", title: "Remove "}).append(
                  $("<span>", { class: "glyphicon glyphicon-remove" })
                )
              )
            )
          )
        )
      )
    )
  }
  $(".sortable").nestedSortable({
    handle: ".move",
    items: "li",
    toleranceElement: "> div",
    listType: "ul",
    placeholder: "placeholder",
    parentNodeFactory: new_node,
    helper: function(e, item) {
      if ( ! item.hasClass("ui-selected") ) {
        item.parent().children(".ui-selected").removeClass("ui-selected")
        item.addClass("ui-selected")
      }

      var selected = item.parent().children(".ui-selected").clone()
      item.data("multidrag", selected).siblings(".ui-selected").remove()
      return $("<li/>").append(selected)
    },
    stop: function(e, ui) {
      var selected = ui.item.data("multidrag")
      ui.item.after(selected)
      ui.item.remove()
      $(".ui-selected").removeClass("ui-selected")
    },
    start: function(event, ui) {
      ui.placeholder.height(ui.item.height())
    },
    isTree: true,
    collapsedClass: "collapsed",
    expandedClass: "expanded"
  })
  $(".sortable").selectable({
    cancel: ".move,input,a,.expand-collapse",
    filter: "li",
    selecting: window.shift_enabled_selecting()
  })
  $(".sortable").on("click", "*[data-action=remove-list]", function(event) {
    event.preventDefault()
    if(confirm("Delete this structure?")) {
      let parent_li = $(this).parents("li").first()
      let child_items = parent_li.children("ul").children()
      parent_li.before(child_items)
      parent_li.remove()
    }
  })
  $("*[data-action=submit-list]").click(function(event) {
    event.preventDefault()
    let element = $(".sortable")
    let serializer = new window.StructureParser(element)
    let url = `/concern/scanned_resources/${element.attr("data-id")}/structure`
    let button = $(this)
    button.text("Saving..")
    button.addClass("disabled")
    $.ajax({
      type: "POST",
      url: url,
      data: JSON.stringify(serializer.serialize),
      dataType: "json",
      contentType: "application/json"
    }).always(() => {
      button.text("Save")
      button.removeClass("disabled")
    })
  })
  $("*[data-action=add-to-list]").click(function(event) {
    event.preventDefault()
    let top_element = $(".sortable")
    let new_element = new_node()
    top_element.prepend(new_element)
  })
  $(".sortable").on("click", ".expand-collapse", function() {
    let parent = $(this).parents("li").first()
    parent.toggleClass("expanded")
    parent.toggleClass("collapsed")
  })
})
