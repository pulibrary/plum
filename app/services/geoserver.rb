require 'active_support/core_ext/hash/indifferent_access'
require 'rgeoserver'
require 'yaml'
require 'erb'

class Geoserver < GeoWorks::Delivery::Geoserver
  attr_reader :config, :workspace_name, :file_set, :file_path

  private

    def base_path(path)
      path.gsub(Plum.config[:geo_derivatives_path], '')
    end
end
