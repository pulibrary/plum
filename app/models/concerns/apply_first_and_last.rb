# frozen_string_literal: true
module ApplyFirstAndLast
  extend ActiveSupport::Concern
  included do
    def apply_first_and_last
      source = list_source
      list_source.save
      return if resource.get_values(:head, cast: false) == source.head_id && resource.get_values(:tail, cast: false) == source.tail_id
      head_will_change!
      tail_will_change!
      resource.set_value(:head, source.head_id)
      resource.set_value(:tail, source.tail_id)
      save!
    end
  end
end
