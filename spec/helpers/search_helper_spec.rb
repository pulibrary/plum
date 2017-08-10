require 'rails_helper'

describe SearchHelper do
  context "#annotation_url" do
    describe "When only an is is given" do
      it "Returns annotaion url" do
        expect(helper.annotation_url("123")).to eq("urn:pmp:123_0")
      end
    end
    describe "When both and id and num are given" do
      it "Returns annotation url" do
        expect(helper.annotation_url("123", "4")).to eq("urn:pmp:123_4")
      end
    end
  end
  context "#manifest_canvas_on_xywh" do
    describe "When id and coordinates are given" do
      it "Returns manifest url" do
        expect(helper.manifest_canvas_on_xywh("123", "0,0,0,0")).to eq(Plum.config[:iiif_url] + "/123/#xywh=0,0,0,0")
      end
    end
  end
end
