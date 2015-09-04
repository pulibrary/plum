class UpdatesMetadata < SimpleDelegator
  delegate :class, to: :__getobj__

  def save
    apply_remote_metadata
    super
  end
end
