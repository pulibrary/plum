Blacklight.onLoad(function() {
  let manager = new FileManagerMember($("#resource-form").parent(), window.save_manager)
  $("#resource-form").parent().data("file_manager_member", manager)
  // Viewing Direction
  new RadioTracker($("#resource-form > div:eq(0)"))
  // Viewing Hint
  new RadioTracker($("#resource-form > div:eq(1)"))
  // OCR Language
  new SelectTracker($("#resource-form select:eq(0)"))
})
