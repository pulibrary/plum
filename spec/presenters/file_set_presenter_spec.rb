require 'rails_helper'

RSpec.describe FileSetPresenter do
  subject { described_class.new(SolrDocument.new(solr_doc), nil) }

  context "when the file is an image" do
    let(:solr_doc) { { mime_type_ssim: ['image/tiff'], width_is: '1024', height_is: '758' } }
    it "reports that it is an image" do
      expect(subject.image?).to be_truthy
    end
  end

  context "when the file is not an image" do
    let(:solr_doc) { { mime_type_ssim: ['application/pdf'] } }
    it "reports that it is not an image" do
      expect(subject.image?).to be_falsy
    end
  end
end
