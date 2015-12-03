require 'rails_helper'

RSpec.describe "curation_concerns/scanned_resources/structure" do
  let(:logical_order) do
    WithProxyForObject::Factory.new(members).new(params)
  end
  let(:params) do
    {
      nodes: [
        {
          label: "Chapter 1",
          nodes: [
            {
              proxy: "a"
            }
          ]
        }
      ]
    }
  end
  let(:members) do
    [
      instance_double(FileSet, id: "a", to_s: "Banana"),
      instance_double(FileSet, id: "b", to_s: "Banana")
    ]
  end
  let(:scanned_resource) { ScannedResource.new("test") }
  before do
    assign(:logical_order, logical_order)
    assign(:presenter, scanned_resource)
    render
  end
  it "renders a li per node" do
    expect(rendered).to have_selector("li", count: 3)
  end
  it "renders a ul per order" do
    expect(rendered).to have_selector("ul", count: 2)
  end
  it "renders labels of chapters" do
    expect(rendered).to have_selector("input[value='Chapter 1']")
  end
  it "renders proxy nodes" do
    expect(rendered).to have_selector("li[data-proxy='a']")
  end
  it "renders unstructured nodes" do
    expect(rendered).to have_selector("li[data-proxy='b']")
  end
end
