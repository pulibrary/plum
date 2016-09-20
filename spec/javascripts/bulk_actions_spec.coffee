BulkActionManager = require("file_manager/bulk_actions")
describe "bulk actions manager", ->
  bulk_manager = null
  beforeEach ->
    loadFixtures("file_manager_three_children.html")
    bulk_manager = new BulkActionManager($("#bulk-actions"))
  describe "bulk panel display", ->
    it "is made to display when there are selected elements", ->
      spyOn(bulk_manager.element, "show")
      bulk_manager.sortable_element.find("li .panel").addClass("ui-selected")
      bulk_manager.sortable_element.trigger("selectablestop")
      expect(bulk_manager.element.show).toHaveBeenCalled()
    it "is hidden when there are no elements", ->
      spyOn(bulk_manager.element, "hide")
      bulk_manager.sortable_element.trigger("selectablestop")
      expect(bulk_manager.element.hide).toHaveBeenCalled()
    it "marks all selected elements' boxes when selected", ->
      bulk_manager.sortable_element.find("li .panel").addClass("ui-selected")
      bulk_manager.sortable_element.trigger("selectablestop")

      # Mark non-paged
      radio = $("#bulk-actions #bulk_hint_non-paged")
      radio.prop('checked', true)
      radio.change()

      expect(bulk_manager.selected_viewing_hint_values).toEqual(["non-paged","non-paged","non-paged"])
