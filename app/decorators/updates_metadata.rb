class UpdatesMetadata < SimpleDelegator
  def save
    apply_external_metadata
    super
  end

  def class
    __getobj__.class
  end
end
