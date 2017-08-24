require 'rails_helper'

RSpec.describe IngestEphemeraService, :admin_set do
  subject { described_class.new(folder, user, project.name, logger) }
  let(:folder) { Rails.root.join('spec', 'fixtures', 'lae_migration', 'folders', '0003d') }
  let(:fileset1) { FactoryGirl.build(:file_set) }
  let(:fileset2) { FactoryGirl.build(:file_set) }
  let(:user) { FactoryGirl.create(:admin) }
  let(:project) { FactoryGirl.create(:ephemera_project) }
  let(:logger) { Logger.new(nil) }
  let(:genres) { Vocabulary.find_or_create_by(label: 'LAE Genres') }
  let(:subjects) { Vocabulary.find_or_create_by(label: 'LAE Subjects') }
  let(:postcards) { VocabularyTerm.find_or_create_by(label: 'Postcards', vocabulary: genres) }
  let(:museums) { VocabularyTerm.find_or_create_by(label: 'Museums', vocabulary: subjects) }
  let(:ingest_service) { instance_double('IngestService') }

  before do
    allow(IngestService).to receive(:new).and_return(ingest_service)
    allow(ingest_service).to receive(:ingest_file).and_return(fileset1, fileset2)
    postcards
    museums
  end

  describe "#ingest" do
    context "with a valid folder" do
      let(:ingested) { EphemeraFolder.last }

      it "ingests an ephemera folder" do
        expect { subject.ingest }.to change { EphemeraFolder.count }.by(1)
        expect(ingested.title).to eq(["En negro y blanco. Del Cordobazo al juicio a las juntas."])
        expect(ingested.file_sets.length).to eq(2)
        expect(ingested.genre.first).to eq(postcards.id.to_s)
        expect(ingested.subject.first).to eq(museums.id.to_s)
      end
    end

    context "when the folder doesn't exist" do
      let(:folder) { Rails.root.join('spec', 'fixtures', 'bogus') }
      let(:logger) { instance_double('Logger') }

      before do
        allow(logger).to receive(:warn)
      end

      it "logs an error" do
        expect { subject.ingest }.not_to change { EphemeraFolder.count }
        expect(logger).to have_received(:warn).with("Error: No such file or directory @ rb_sysopen - #{folder}/foxml")
      end
    end
  end

  describe "#lookup" do
    it "finds genres" do
      graph = RDF::Graph.new
      graph << [RDF::URI.new, RDF::Vocab::DC.format, "Postcards"]
      expect(subject.lookup(graph, RDF::Vocab::DC.format, "LAE Genres")).to eq([postcards.id.to_s])
    end
    it "finds subjects" do
      graph = RDF::Graph.new
      graph << [RDF::URI.new, RDF::Vocab::DC.subject, "Museums"]
      expect(subject.lookup(graph, RDF::Vocab::DC.subject, nil)).to eq([museums.id.to_s])
    end
    it "handles missing data" do
      graph = RDF::Graph.new
      graph << [RDF::URI.new, RDF::Vocab::DC.format, "Flyers"]
      expect(subject.lookup(graph, RDF::Vocab::DC.format, "LAE Genres")).to eq([nil])
    end
  end
end
