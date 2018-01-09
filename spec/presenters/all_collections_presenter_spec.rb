# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AllCollectionsPresenter do
  subject { described_class.new }

  it "can be used to build a manifest" do
    expect { AllCollectionsManifestBuilder.new(subject).to_json }.not_to raise_error
  end

  it "has a title" do
    expect(subject.title).to eq ["Plum Collections"]
  end

  it "has a description" do
    expect(subject.description).to eq "All collections which are a part of Plum."
  end
end
