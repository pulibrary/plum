require 'rails_helper'

RSpec.describe METSDocument do
  let(:mets_file) { Rails.root.join("spec", "fixtures", "pudl0001-4612596.mets") }
  let(:mets_file_rtl) { Rails.root.join("spec", "fixtures", "pudl0032-ns73.mets") }
  let(:mets_file_multi) { Rails.root.join("spec", "fixtures", "pudl0001-4609321-s42.mets") }
  let(:tiff_file) { Rails.root.join("spec", "fixtures", "files", "color.tif") }
  let(:structure) { { nodes: [{ label: 'recto', proxy: 'pkc90' }] } }
  let(:structure_phys1) { {
    nodes: [{
      label: "upper cover", nodes: [{
        label: "upper cover. cover", proxy: "gylme"
      }, {
        label: "upper cover. pastedown", proxy: "l898s"
      }]
    }, {
      label: "gathering 1", nodes: [{
        label: "leaf 1, gathering 1/1", nodes: [{
          label: "gathering 1. leaf 1, gathering 1/1. recto", proxy: "itc6o"
        }]
      }]
    }]
  }}

  describe "identifiers" do
    subject { described_class.new mets_file }

    it "has an ark id" do
      expect(subject.ark_id).to eq('ark:/88435/5m60qr98h')
    end

    it "has a bib id" do
      expect(subject.bib_id).to eq('4612596')
    end

    it "has a pudl id" do
      expect(subject.pudl_id).to eq('pudl0001/4612596')
    end

    it "has structure" do
      expect(subject.structure).to eq(structure)
    end
  end

  describe "files" do
    subject { described_class.new mets_file_rtl }

    it "has a thumbnail url" do
      expect(subject.thumbnail_path).to eq('/tmp/pudl0032/ns73/00000001.tif')
    end

    it "has an array of files" do
      expect(subject.files.length).to eq(189)
    end

    it "has no options for files present in the structMap" do
      expect(subject.file_opts(subject.files.first)).to eq({})
    end

    it "has marks a file not present in the structMap as non-paged" do
      expect(subject.file_opts(subject.files.last)).to eq(viewing_hint: 'non-paged')
    end

    it "has a decorated file" do
      decorated = subject.decorated_file(path: tiff_file, mime_type: 'image/tiff')
      expect(decorated.mime_type).to eq('image/tiff')
      expect(decorated.original_filename).to eq('color.tif')
    end
  end

  describe "viewing direction" do
    context "a left-to-right object" do
      subject { described_class.new mets_file }

      it "is right-to-left" do
        expect(subject.right_to_left).to be false
      end
      it "has a right-to-left viewing direction" do
        expect(subject.viewing_direction).to eq('left-to-right')
      end
    end

    context "a right-to-left object" do
      subject { described_class.new mets_file_rtl }

      it "is right-to-left" do
        expect(subject.right_to_left).to be true
      end
      it "has a right-to-left viewing direction" do
        expect(subject.viewing_direction).to eq('right-to-left')
      end
    end
  end

  describe "multi-volume" do
    context "a single-volume mets file" do
      subject { described_class.new mets_file }

      it "is not multi-volume" do
        expect(subject.multi_volume?).to be false
      end

      it "has no volume ids" do
        expect(subject.volume_ids).to eq []
      end
    end

    context "a multi-volume mets file" do
      subject { described_class.new mets_file_multi }

      it "is multi-volume" do
        expect(subject.multi_volume?).to be true
      end

      it "has volume ids" do
        expect(subject.volume_ids).to eq ['phys1', 'phys2']
      end

      it "has volume labels" do
        expect(subject.label_for_volume('phys1')).to eq 'first volume'
      end

      it "has volume file lists" do
        expect(subject.files_for_volume('phys1').length).to eq 3
      end

      it "has volume structure" do
        expect(subject.structure_for_volume('phys1')).to eq(structure_phys1)
      end
    end
  end
end
