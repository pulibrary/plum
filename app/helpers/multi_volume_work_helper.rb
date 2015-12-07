module MultiVolumeWorkHelper
  def multi_volume_work_page_header
    h = content_tag(:h1, @presenter.title)
    h += multi_volume_work_breadcrumb
    h.html_safe
  end

  def multi_volume_work_breadcrumb
    content_tag(:ul, class: 'breadcrumb') do
      content_tag(:li, @presenter.human_readable_type, class: 'active')
    end
  end
end
