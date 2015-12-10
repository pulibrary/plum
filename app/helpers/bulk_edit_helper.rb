module BulkEditHelper
  def bulk_edit_page_header
    h = content_tag(:h1, 'Bulk Edit')
    h += bulk_edit_breadcrumb
    h.html_safe
  end

  def bulk_edit_breadcrumb
    content_tag(:ul, class: 'breadcrumb') do
      bulk_edit_parent_work
    end
  end

  def bulk_edit_parent_work
    return '' unless @presenter
    title = 'Back to Parent'
    link = content_tag(:a, title,
                       title: @presenter.id,
                       href: bulk_edit_parent_path)
    content_tag(:li, link)
  end

  def bulk_edit_parent_path
    Rails.application.routes.url_helpers
      .curation_concerns_scanned_resource_path(@presenter.id)
  end
end
