class CompositeDecorator
  attr_reader :decorators
  def initialize(*decorators)
    @decorators = decorators.flatten.compact
  end

  def new(obj)
    decorators.each do |decorator|
      obj = decorator.new(obj)
    end
    obj
  end
end
