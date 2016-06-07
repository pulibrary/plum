module CurationConcernsHelper
  include ::BlacklightHelper
  include CurationConcerns::MainAppHelpers

  def default_icon_fallback
    "this.src='#{image_path('default.png')}'".html_safe
  end
end
