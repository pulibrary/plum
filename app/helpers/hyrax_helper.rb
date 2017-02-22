module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::HyraxHelperBehavior

  def default_icon_fallback
    "this.src='#{image_path('default.png')}'".html_safe
  end

  def can_ever_create_works?
    can = false
    Hyrax.config.curation_concerns.each do |curation_concern_type|
      break if can
      can = can?(:create, curation_concern_type)
    end
    can
  end
end
