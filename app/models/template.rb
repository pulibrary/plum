# frozen_string_literal: true
class Template < ApplicationRecord
  serialize :params, Hash
end
