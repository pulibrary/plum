# frozen_string_literal: true
class RTLIndexPresenter < ::Blacklight::IndexPresenter
  include RTLPresenter

  def field_value(*args)
    to_list(super)
  end

  def label(*args)
    if args.first == @configuration.view_config(:show).title_field
      to_list(super)
    else
      super
    end
  end
end
