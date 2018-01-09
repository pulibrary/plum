# frozen_string_literal: true
class GeoWorksService
  class_attribute :geo_works_classes
  self.geo_works_classes = [ImageWork, RasterWork, VectorWork, MapSet]

  attr_reader :record
  def initialize(record)
    @record = record
  end

  def geo_work?
    geo_works_classes.include?(record.model_name.to_s.constantize)
  end
end
