import ServerUploader from "server_uploader"
import BulkLabeler from "bulk_labeler/bulk_label"
import ModalViewer from "modal_viewer"
import PlumFileManager from "file_manager/plum"
import StructureManager from "structure_manager"
import UniversalViewer from "universal_viewer"
import SaveWorkResizeHack from "save_work_resize_hack"
export default class Initializer {
  constructor() {
    this.initialize_bootstrap_select()
    this.server_uploader = new ServerUploader
    this.bulk_labeler = new BulkLabeler
    this.modal_viewer = new ModalViewer
    this.initialize_timepicker()
    this.initialize_plum_file_manager()
    this.structure_manager = new StructureManager
    this.universal_viewer = new UniversalViewer
    this.save_work_resize_hack = new SaveWorkResizeHack
  }

  initialize_bootstrap_select() {
    $("optgroup").addClass("closed")
    $("select[multiple='multiple']").selectpicker({})
    $(".datatable").DataTable()
  }

  initialize_timepicker() {
    $(".timepicker").datetimepicker({
      timeFormat: "HH:mm:ssZ",
      separator: "T",
      dateFormat: "yy-mm-dd",
      timezone: "0",
      showTimezone: false,
      showHour: false,
      showMinute: false,
      showSecond: false,
      hourMax: 0,
      minuteMax: 0,
      secondMax: 0
    })
  }

  initialize_plum_file_manager() {
    this.plum_file_manager = new PlumFileManager
  }
}
