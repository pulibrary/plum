require 'rails_helper'

RSpec.describe "hyrax/base/_structure_node.html.erb" do
  let(:node) do
    WithProxyForObject::Factory.new([member]).new(params)
  end
  let(:params) do
    {
      "proxy": "a"
    }
  end
  let(:member) do
    f = FileSet.new(id: "a")
    FileSetPresenter.new(SolrDocument.new(f.to_solr), nil)
  end
  before do
    stub_blacklight_views
    render partial: "hyrax/base/structure_node", locals: { node: node }
  end
  it "displays an openseadragon tag for proxies" do
    expect(rendered).to have_selector("*[data-modal-manifest='#{IIIFPath.new(member.id)}/info.json']")
  end
end
