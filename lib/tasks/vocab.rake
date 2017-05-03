namespace :vocab do
  task load: :environment do
    file = ENV['CSV']
    name = ENV['NAME']
    columns = {
      label: ENV['LABEL'] || 'label',
      tgm: ENV['TGM'] || 'tgm_label',
      lcsh: ENV['LCSH'] || 'lcsh_label',
      uri: ENV['URI'] || 'uri',
      category: ENV['CATEGORY']
    }

    IngestVocab.ingest(file, name, columns)
  end
end
