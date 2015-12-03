jQuery(() => {
  $(".sortable").nestedSortable({
    handle: "div",
    items: "li",
    toleranceElement: "> div",
    listType: "ul",
    placeholder: "placeholder",
    isAllowed: function(placeholder, placeholderParent) {
      if($(placeholderParent).attr("data-proxy")) {
        return false
      } else {
        return true
      }
    }
  })
  $(".sortable").on("click", "*[data-action=remove-list]", function(event) {
    event.preventDefault()
    let parent_li = $(this).parents("li").first()
    let child_items = parent_li.find("li")
    parent_li.before(child_items)
    parent_li.remove()
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
    let new_element = $("<li>").append(
      $("<div>").append(
        $("<div>", { class: "panel panel-default" }).append(
          $("<div>", { class: "panel-heading" }).append(
            $("<div>", { class: "title" }).append(
              $("<input>", { type: "text", name: "label", id: "label" })
            )
          ).append(
            $("<div>", { class: "toolbar" }).append(
              $("<a>", { href: "", "data-action": "remove-list", title: "Remove "}).append(
                $("<span>", { class: "glyphicon glyphicon-remove" })
              )
            )
          )
        )
      )
    )
    top_element.append(new_element)
  })
})
