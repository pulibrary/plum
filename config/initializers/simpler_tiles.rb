# frozen_string_literal: true
module SimplerTiles
  class << self
    def config
      @config ||= Configuration.new
    end
  end

  class Configuration
    attr_reader :settings
    attr_writer :bg_color,
                :fill,
                :stroke,
                :weight,
                :line_cap,
                :line_join,
                :radius

    def initialize
      @settings ||= File.exist?(config_file) ? YAML.load_file(config_file) : {}
    end

    def config_file
      File.join(Rails.root, 'config/simpler_tiles.yml')
    end

    def to_h
      {
        'stroke' => stroke,
        'line-cap' => line_cap,
        'line-join' => line_join,
        'weight' => weight,
        'fill' => fill,
        'radius' => radius
      }
    end

    def bg_color
      @bg_color ||= settings.fetch('bg_color', '#ffffff00')
    end

    def fill
      @fill ||= settings.fetch('fill', '#e4e3ea')
    end

    def stroke
      @stroke ||= settings.fetch('stroke', '#483d8b')
    end

    def weight
      @weight ||= settings.fetch('weight', '0.3')
    end

    def line_cap
      @line_cap ||= settings.fetch('line_cap', 'square')
    end

    def line_join
      @line_join ||= settings.fetch('line_join', 'miter')
    end

    def radius
      @radius ||= settings.fetch('radius', '2')
    end
  end
end
