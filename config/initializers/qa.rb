Vocabulary.all.each do |vocab|
  Qa::Authorities::Local.register_subauthority(vocab.label, 'VocabularySubauthority')
end
