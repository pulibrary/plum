module StructureHelper
  def structure_page_header
    h = content_tag(:h1, 'Edit Structure')
    h += bulk_edit_breadcrumb
    h.html_safe
  end

  private

    def bulk_edit_breadcrumb
      content_tag(:ul, class: 'breadcrumb') do
        (bulk_edit_grandparent_work + bulk_edit_parent_work + header).html_safe
      end
    end

    def bulk_edit_parent_work
      return '' unless @presenter
      link = content_tag(:a, @presenter.page_title,
                         title: @presenter.id,
                         href: bulk_edit_parent_path(@presenter, @parent_presenter))
      content_tag(:li, link)
    end

    def bulk_edit_grandparent_work
      return '' unless @parent_presenter
      link = content_tag(:a, @parent_presenter.page_title,
                         title: @parent_presenter.id,
                         href: bulk_edit_parent_path(@parent_presenter))
      content_tag(:li, link)
    end

    def header
      content_tag(:li, 'Edit Structure', class: :active)
    end

    def bulk_edit_parent_path(presenter, parent_presenter = nil)
      ContextualPath.new(presenter, parent_presenter).show
    end
end
