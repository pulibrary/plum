class DefaultValues < Decorator
  def rights_statement
    result = super
    if result.blank? && !persisted?
      "http://rightsstatements.org/vocab/NKC/1.0/"
    else
      result
    end
  end
end
