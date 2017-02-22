class PersistPairtreeDerivatives < Hyrax::PersistDerivatives
  def self.derivative_path_factory
    PairtreeDerivativePath
  end
end
