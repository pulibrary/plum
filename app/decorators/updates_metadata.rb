class UpdatesMetadata < Decorator
  def save
    apply_remote_metadata
    super
  end
end
