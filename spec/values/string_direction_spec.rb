require 'rails_helper'

RSpec.describe String do
  describe "#dir" do
    context "when given an arabic string" do
      subject { "حكاية" }
      it "returns rtl" do
        expect(subject.dir).to eq "rtl"
      end
    end
    context "when given an english string" do
      subject { "string" }
      it "returns ltr" do
        expect(subject.dir).to eq "ltr"
      end
    end
  end
end
