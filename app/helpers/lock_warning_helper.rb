module LockWarningHelper
  def lock_warning
    return nil unless lock_id? && @presenter.try(:lock?)
    h = content_tag(:h1, 'This object is currently queued for processing.', class: 'alert alert-warning')
    h.html_safe
  end

  private

    def lock_id?
      @presenter.respond_to?(:id) && !@presenter.try(:id).blank?
    end
end
