# Generated via
#  `rails generate hyrax:work EphemeraBox`
require 'rails_helper'

RSpec.describe EphemeraBox do
  subject(:box) { FactoryGirl.build(:ephemera_box) }
  it "has a valid factory" do
    expect(box).to be_valid
  end
  describe "#box_number=" do
    it "sets the title" do
      subject.box_number = [3]
      expect(subject.title).to eq ["Box Number 3"]
    end
    it "is invalid when it's not set" do
      subject.box_number = []
      expect(subject).not_to be_valid
    end
  end
  describe "#barcode" do
    it "is invalid when it's not set" do
      subject.barcode = []
      expect(subject).not_to be_valid
    end
    it "is invalid when it's set to a non-valid barcode" do
      subject.barcode = ["bla"]
      expect(subject).not_to be_valid
    end
    it "is invalid when set to a numeric invalid barcode" do
      subject.barcode = ["1"]
      expect(subject).not_to be_valid
    end
  end
end
