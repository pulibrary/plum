module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::MainAppHelpers

  def default_icon_fallback
    "this.src='#{image_path('default.png')}'".html_safe
  end
end
