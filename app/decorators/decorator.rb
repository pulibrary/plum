class Decorator < SimpleDelegator
  include GlobalID::Identification
  delegate :class, :is_a?, :instance_of?, to: :__getobj__
end
