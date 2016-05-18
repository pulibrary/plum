module ScannedResourceHelper
  def scanned_resource_page_header
    h = content_tag(:h1, @presenter.title)
    h += scanned_resource_breadcrumb
    h.html_safe
  end

  def scanned_resource_parent_id
    return unless @presenter.solr_document
                  .fetch('ordered_by_ssim', []).include? params[:parent_id]
    params[:parent_id]
  end

  def scanned_resource_parent_presenter
    return unless scanned_resource_parent_id
    @parent_presenter ||= CurationConcerns::PresenterFactory
                          .build_presenters([scanned_resource_parent_id],
                                            MultiVolumeWorkShowPresenter,
                                            @presenter.current_ability)
    @parent_presenter.first
  end

  def scanned_resource_breadcrumb
    content_tag(:ul, class: 'breadcrumb') do
      concat(scanned_resource_parent_work)
      concat(scanned_resource_work_type)
    end
  end

  def scanned_resource_parent_work
    return '' unless scanned_resource_parent_presenter
    title = scanned_resource_parent_presenter.title
    link = content_tag(:a, truncate(title.first),
                       title: title.first,
                       href: scanned_resource_parent_path)
    content_tag(:li, link)
  end

  def scanned_resource_work_type
    content_tag(:li, @presenter.human_readable_type, class: 'active')
  end

  def scanned_resource_parent_path
    Rails.application.routes.url_helpers
      .curation_concerns_multi_volume_work_path(scanned_resource_parent_id)
  end
end
