class WordBoundariesCreator < Hydra::Derivatives::Runner
  def self.processor_class
    Processors::WordBoundaries
  end
end
