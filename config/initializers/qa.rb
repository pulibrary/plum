# frozen_string_literal: true
if ActiveRecord::Base.connection.data_source_exists? Vocabulary.table_name
  Vocabulary.all.each do |vocab|
    Qa::Authorities::Local.register_subauthority(vocab.label, 'VocabularySubauthority')
  end
end
