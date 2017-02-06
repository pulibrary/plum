module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::HyraxHelperBehavior

  def default_icon_fallback
    "this.src='#{image_path('default.png')}'".html_safe
  end
end
