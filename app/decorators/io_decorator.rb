# frozen_string_literal: true
class IoDecorator < Hydra::Derivatives::IoDecorator
  def original_filename
    original_name
  end

  def content_type
    mime_type
  end
end
