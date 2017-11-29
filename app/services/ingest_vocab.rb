# frozen_string_literal: true
require 'csv'

class IngestVocab
  def self.ingest(file, name, columns)
    logger = Logger.new(STDOUT)

    vocab = Vocabulary.find_or_create_by(label: name) if name
    CSV.foreach(file, headers: true) do |obj|
      row = obj.to_h
      category_label = fetch(row, columns, :category)
      category = Vocabulary.find_or_create_by!(label: category_label, parent: vocab) if category_label
      VocabularyTerm.create!(
        label: fetch(row, columns, :label),
        tgm_label: fetch(row, columns, :tgm_label),
        lcsh_label: fetch(row, columns, :lcsh_label),
        uri: fetch(row, columns, :uri),
        vocabulary: category || vocab
      )
      logger.info row[columns[:label]]
    end
  end

  def self.fetch(row, columns, key)
    return unless columns[key]
    row[columns[key]]
  end
end
