class PersistPairtreeDerivatives < CurationConcerns::PersistDerivatives
  def self.derivative_path_factory
    PairtreeDerivativePath
  end
end
