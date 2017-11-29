# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DateValue do
  context "with a single date" do
    subject { described_class.new(["1999-01-01T00:00:00Z"]) }

    it "renders the date as mm/dd/yy" do
      expect(subject.to_a).to eq ["01/01/1999"]
    end
  end

  context "with a date range" do
    subject { described_class.new(["1999-01-01T00:00:00Z/1999-01-31T00:00:00Z"]) }

    it "renders the date as mm/dd/yy" do
      expect(subject.to_a).to eq ["01/01/1999-01/31/1999"]
    end
  end

  context "with a date range starting on 1/1 and ending on 12/31" do
    subject { described_class.new(["1999-01-01T00:00:00Z/2000-12-31T23:59:59Z"]) }

    it "renders the date as mm/dd/yy" do
      expect(subject.to_a).to eq ["1999-2000"]
    end
  end
end
