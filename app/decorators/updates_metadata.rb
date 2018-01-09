# frozen_string_literal: true
class UpdatesMetadata < Decorator
  def save
    apply_remote_metadata if changed?
    super
  end
end
