if ActiveRecord::Base.connection.table_exists? Vocabulary.table_name
  Vocabulary.all.each do |vocab|
    Qa::Authorities::Local.register_subauthority(vocab.label, 'VocabularySubauthority')
  end
end
