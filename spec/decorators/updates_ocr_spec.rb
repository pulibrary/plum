require 'rails_helper'

RSpec.describe UpdatesOCR do
  subject { described_class.new(FactoryGirl.build(:scanned_resource)) }
  let(:file_set) { FactoryGirl.create(:file_set, content: file) }
  let(:file) { File.open(Rails.root.join("spec", "fixtures", "files", "page18.tif")) }
  before do
    allow(File).to receive(:open).and_call_original
    allow(File).to receive(:open).with(file_set.local_file).and_return(file)
    subject.ordered_members << file_set
    subject.save
  end

  around { |example| perform_enqueued_jobs(&example) }

  context "when ocr_language is changed" do
    it "regenerates OCR derivatives" do
      stub_language("ita+eng", "Italian & English")
      stub_language("eng+ita", "Italian & English")
      stub_language("eng", "English")
      allow_any_instance_of(FileSet).to receive(:mime_type_storage).and_return(['image/tiff'])
      file_set.create_derivatives(file.path)
      file_set.save
      old_content = file_set.to_solr["full_text_tesim"]
      subject.ocr_language = ["ita", "eng"]
      subject.save

      document = ActiveFedora::SolrService.query("id:#{file_set.id}").first
      expect(document["full_text_tesim"].first).not_to eq old_content
    end

    def stub_language(language, content)
      allow(Processors::OCR).to receive(:encode).with(anything, { options: "-l #{language}" }, anything) do |*args|
        File.open(args.last, 'w') do |f|
          f.write content
        end
      end
    end
  end
end
