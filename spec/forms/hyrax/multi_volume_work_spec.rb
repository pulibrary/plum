require 'rails_helper'

RSpec.describe Hyrax::MultiVolumeWorkForm do
  subject { described_class.new(work, nil, nil) }
  let(:work) { MultiVolumeWork.new }

  it "doesn't initialize description" do
    expect(subject.description).to eq nil
  end
end
