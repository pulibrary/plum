class UpdatesMetadata < SimpleDelegator
  delegate :class, to: :__getobj__

  def save
    apply_external_metadata
    super
  end
end
