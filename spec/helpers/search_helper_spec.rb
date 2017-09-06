require 'rails_helper'

describe SearchHelper do
  context "#annotation_url" do
    describe "When only an ID is given" do
      it "Returns annotaion url" do
        expect(helper.annotation_url("123")).to eq("urn:pmp:123_0")
      end
    end
    describe "When both an ID and a sequence number are given" do
      it "Returns annotation url" do
        expect(helper.annotation_url("123", "4")).to eq("urn:pmp:123_4")
      end
    end
  end
  context "#manifest_canvas_on_xywh" do
    describe "When id and coordinates are given" do
      it "Returns manifest url" do
        expect(helper.manifest_canvas_on_xywh("http://sample.com/123", "456", "0,0,0,0")).to eq("http://sample.com/123/manifest/canvas/456#xywh=0,0,0,0")
      end
    end
  end
end
