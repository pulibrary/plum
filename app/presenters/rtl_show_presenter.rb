# frozen_string_literal: true
class RTLShowPresenter < ::Blacklight::ShowPresenter
  include RTLPresenter

  def field_value(*args)
    to_list(super)
  end
end
