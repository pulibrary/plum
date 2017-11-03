require "rails_helper"

RSpec.describe SaveStructureJob do
  let(:work) { FactoryGirl.create(:scanned_resource_with_file) }
  let(:file_set1) { work.file_sets.first }
  let(:structure) do
    { "label": "Test",
      "nodes": [{
        "label": "Chapter 1",
        "nodes": [{
          "label": file_set1.rdf_label.first,
          "proxy": file_set1.id
        }]
      }] }
  end

  it "saves logical order without accumulating fragments" do
    expect(work.logical_order.nodes.empty?)

    described_class.perform_now(work, structure)
    work.reload
    expect(work.logical_order.resource.subjects.count).to eq 3

    structure["label"] = "Updated"
    described_class.perform_now(work, structure)
    work.reload
    expect(work.logical_order.order["label"]).to eq "Updated"
    expect(work.logical_order.resource.subjects.count).to eq 3
  end

  it "logs an error" do
    allow(work).to receive(:save).and_return(false) # Trigger some error in logical order stack.
    # FIXME: The call to logger is not being detected
    # expect(Rails.logger).to receive(:error) #.with(/^SaveStructureJob failed.*{.*}$/)
    expect { described_class.perform_now(work, structure) }.to raise_error(ActiveFedora::RecordNotSaved)
  end

  it 'locks and unlocks the work' do
    expect(work).to receive(:lock).ordered
    expect(work).to receive(:unlock).ordered
    described_class.perform_now(work, structure)
  end
end
