SelectTracker = require("file_manager/select_tracker")
describe "SelectTracker", ->
  select_tracker = null
  parent_persister = {
    push_changed: () => {},
    mark_unchanged: () => {}
  }
  element = null
  beforeEach ->
    loadFixtures("trackable_select.html")
    element = $("select")
    $("#parent").data("file_manager_member", parent_persister)
    select_tracker = new SelectTracker(element)
  it "tags the element with itself for the file manager", ->
    expect(element.data("tracker")).toEqual(select_tracker)
  describe "is_changed", ->
    it "returns false when nothing has changed", ->
      expect(select_tracker.is_changed).toEqual(false)
    it "returns true when the selection is changed", ->
      spyOn(parent_persister, "push_changed")
      element.val("ara").change()

      expect(parent_persister.push_changed).toHaveBeenCalled()
      expect(select_tracker.is_changed).toEqual(true)
    it "returns false when button is changed back to normal", ->
      spyOn(parent_persister, "mark_unchanged")
      element.val("ara").change()
      element.val(null).change()

      expect(select_tracker.is_changed).toEqual(false)
      expect(parent_persister.mark_unchanged).toHaveBeenCalled()
  describe "#reset", ->
    it "resets changed status", ->
      element.val("ara").change()
      select_tracker.reset()

      expect(select_tracker.is_changed).toEqual(false)
