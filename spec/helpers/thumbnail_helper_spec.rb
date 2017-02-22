require 'rails_helper'

describe ThumbnailHelper do
  subject { helper }

  before do
    allow(subject).to receive(:thumbnail_url).and_return('thumbnail.jpg')
  end

  context 'when document is a geo FileSet' do
    let(:file_set) { FactoryGirl.create(:file_set, geo_mime_type: 'application/vnd.geo+json') }
    let(:document) do
      FileSetPresenter.new(
        SolrDocument.new(
          file_set.to_solr
        ), nil
      )
    end

    xit 'returns a path to the thumbnail image' do
      expect(subject).to receive(:link_to_document).with(document, /<img src=\"\/images\/thumbnail.jpg/)
      subject.plum_thumbnail_path(document)
    end
  end

  context 'when document is a VectorWork' do
    let(:vector_work) { FactoryGirl.create(:vector_work) }
    let(:document) do
      GeoWorks::VectorWorkShowPresenter.new(
        SolrDocument.new(
          vector_work.to_solr
        ), nil
      )
    end

    it 'returns a path to the thumbnail image' do
      expect(subject).to receive(:link_to_document).with(document, /<img src=\"\/images\/thumbnail.jpg/)
      subject.plum_thumbnail_path(document)
    end
  end

  context 'when document is a ScannedResource' do
    let(:scanned_resource) { FactoryGirl.create(:scanned_resource) }
    let(:document) do
      ScannedResourceShowPresenter.new(
        SolrDocument.new(
          scanned_resource.to_solr
        ), nil
      )
    end

    before do
      allow(document).to receive(:thumbnail_id).and_return('abcdefg')
    end

    it 'returns a path to the iiif thumbnail' do
      expect(subject).to receive(:link_to_document).with(document, /ab%2Fcd%2Fef%2Fg-intermediate_file.jp2/)
      subject.plum_thumbnail_path(document)
    end
  end
end
