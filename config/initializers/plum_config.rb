module Plum
  def config
    @config ||= YAML.load_file(Rails.root.join('config/config.yml'))[Rails.env].with_indifferent_access
  end

  module_function :config
end

Hydra::Derivatives.kdu_compress_recipes = Plum.config['jp2_recipes']
