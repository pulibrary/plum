# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EphemeraProject, type: :model do
  it "has a name" do
    project = described_class.new name: "Test Project"
    expect(project.name).to eq("Test Project")
  end
end
