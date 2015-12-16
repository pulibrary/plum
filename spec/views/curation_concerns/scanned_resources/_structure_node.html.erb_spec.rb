require 'rails_helper'

RSpec.describe "curation_concerns/scanned_resources/_structure_node.html.erb" do
  let(:node) do
    WithProxyForObject::Factory.new([member]).new(params)
  end
  let(:params) do
    {
      "proxy": "a"
    }
  end
  let(:member) do
    f = FileSet.new("a")
    FileSetPresenter.new(SolrDocument.new(f.to_solr), nil)
  end
  before do
    stub_blacklight_views
    render partial: "curation_concerns/scanned_resources/structure_node", locals: { node: node }
  end
  it "displays an openseadragon tag for proxies" do
    expect(rendered).to have_selector("*[data-modal-manifest='#{IIIFPath.new(member.id)}']")
  end
end
