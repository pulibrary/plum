# frozen_string_literal: true
class TouchParentJob < ApplicationJob
  queue_as :lowest

  def perform(file_set)
    file_set.in_works.each(&:update_index)
  end
end
