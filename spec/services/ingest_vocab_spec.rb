require 'rails_helper'

RSpec.describe IngestVocab do
  let(:genre_csv) { Rails.root.join('spec', 'fixtures', 'lae_genres.csv') }
  let(:subject_csv) { Rails.root.join('spec', 'fixtures', 'lae_subjects.csv') }
  before do
    allow_any_instance_of(Logger).to receive(:info)
  end

  describe "#ingest" do
    context "with categories" do
      before do
        described_class.ingest(subject_csv, nil, label: 'subject', category: 'category', uri: 'uri')
      end

      it "loads the terms with categories" do
        expect(VocabularyTerm.all.map(&:label)).to contain_exactly('Agricultural development projects', 'Architecture')
        expect(Vocabulary.all.map(&:label)).to contain_exactly('Agrarian and rural issues', 'Arts and culture')
      end
    end

    context "without categories" do
      before do
        described_class.ingest(genre_csv, "Genres", label: 'pul_label', tgm_label: 'tgm_label', lcsh_label: 'lcsh_label', uri: 'uri')
      end

      it "loads the terms with categories" do
        expect(VocabularyTerm.all.map(&:label)).to contain_exactly('Brochures', 'Electoral paraphernalia')
        expect(VocabularyTerm.all.map(&:lcsh_label)).to include('Political collectibles')
        expect(VocabularyTerm.all.map(&:tgm_label)).to include('Leaflets')
      end
    end
  end
end
