class OCRCreator < Hydra::Derivatives::Runner
  def self.processor_class
    Processors::OCR
  end
end
