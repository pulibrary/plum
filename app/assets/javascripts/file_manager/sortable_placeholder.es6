Blacklight.onLoad(function() {
  $( "#sortable" ).on( "sortstart", function( event, ui ) {
    let found_element = $("#sortable").children("li[data-reorder-id]").first()
    ui.placeholder.width(found_element.width())
    ui.placeholder.height(found_element.height())
  })
})
