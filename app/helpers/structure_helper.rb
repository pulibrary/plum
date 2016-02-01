module StructureHelper
  include BulkEditHelper

  def structure_page_header
    h = content_tag(:h1, 'Edit Structure')
    h += bulk_edit_breadcrumb
    h.html_safe
  end
end
