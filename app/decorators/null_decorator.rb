class NullDecorator
  class << self
    def new(obj)
      obj
    end
  end
end
