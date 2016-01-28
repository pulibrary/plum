class Decorator < SimpleDelegator
  delegate :class, :is_a?, :instance_of?, to: :__getobj__
end
