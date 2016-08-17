RadioTracker = require("file_manager/radio_tracker")
describe "RadioTracker", ->
  radio_tracker = null
  parent_persister = {
    push_changed: () => {},
    mark_unchanged: () => {}
  }
  element = null
  beforeEach ->
    loadFixtures("trackable_radio_buttons.html")
    element = $("#trackable-radio-buttons")
    $("#filez").data("file_manager_member", parent_persister)
    radio_tracker = new RadioTracker(element)
  describe "checked_element", ->
    it "returns the checked element", ->
      expect(radio_tracker.checked_element).toEqual(element.find("input").first())
      element.find("input:eq(0)").prop("checked", null)
      element.find("input:eq(1)").prop("checked", "checked")
      element.find("input:eq(1)").change()
      expect(radio_tracker.checked_element).toEqual(element.find("input:eq(1)"))
  it "tags the element with itself for the file manager", ->
    expect(element.data("tracker")).toEqual(radio_tracker)
  describe "is_changed", ->
    it "returns false when nothing has changed", ->
      expect(radio_tracker.is_changed).toEqual(false)
    it "returns true when the button is changed", ->
      spyOn(parent_persister, "push_changed")
      element.find("input[type=radio]:eq(1)").click()

      expect(parent_persister.push_changed).toHaveBeenCalled()
      expect(radio_tracker.is_changed).toEqual(true)
    it "returns false when button is changed back to normal", ->
      spyOn(parent_persister, "mark_unchanged")
      element.find("input:eq(1)").click()
      element.find("input:eq(0)").click()

      expect(radio_tracker.is_changed).toEqual(false)
      expect(parent_persister.mark_unchanged).toHaveBeenCalled()
  describe "#reset", ->
    it "resets changed status", ->
      element.find("input:eq(1)").click()
      radio_tracker.reset()

      expect(radio_tracker.is_changed).toEqual(false)
