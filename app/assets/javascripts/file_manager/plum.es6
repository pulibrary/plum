import RadioTracker from "file_manager/radio_tracker"
import SelectTracker from "file_manager/select_tracker"
import {FileManagerMember} from "curation_concerns/file_manager/member"
export default class PlumFileManager {
  constructor() {
    this.initialize_radio_buttons()
    this.sortable_placeholder()
    this.manage_iiif_fields()
  }

  initialize_radio_buttons() {
    $("*[data-reorder-id] .file_set_viewing_hint").each((index, element) => {
      new RadioTracker($(element))
    })
  }

  sortable_placeholder() {
    $( "#sortable" ).on( "sortstart", function( event, ui ) {
      let found_element = $("#sortable").children("li[data-reorder-id]").first()
      ui.placeholder.width(found_element.width())
      ui.placeholder.height(found_element.height())
    })
  }

  manage_iiif_fields() {
    let manager = new FileManagerMember($("#resource-form").parent(), window.curation_concerns.file_manager.save_manager)
    $("#resource-form").parent().data("file_manager_member", manager)
    // Viewing Direction
    new RadioTracker($("#resource-form > div:eq(0)"))
    // Viewing Hint
    new RadioTracker($("#resource-form > div:eq(1)"))
    // OCR Language
    new SelectTracker($("#resource-form select:eq(0)"))
  }
}
