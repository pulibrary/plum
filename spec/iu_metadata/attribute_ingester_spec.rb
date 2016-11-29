require 'rails_helper'

RSpec.describe IuMetadata::AttributeIngester do
  let(:att_ingester) { described_class.new(id, attributes) }
  let(:id) { 'file:///foo/bar' }
  let(:foo_context) { { "@context" => { "id" => "@id", "foo" => { "@id" => "http://opaquenamespace.org/ns/mods/titleForSort" } } } }

  describe "#raw_attributes" do
    context "without a context mapping" do
      let(:attributes) { { foo: 'bar' } }
      it "drops the attribute" do
        expect(att_ingester.raw_attributes['foobar']).to be_nil
      end
    end
    context "with a context mapping" do
      context "without a destination" do
        let(:attributes) { { title: 'foobar' } }
        let(:context) { Hash.new }
        let(:att_ingester) { described_class.new(id, attributes, context: context) }
        it "drops the attribute" do
          expect(att_ingester.raw_attributes['title']).to be_nil
        end
      end
      context "with a destination" do
        context "with a different name" do
          let(:attributes) { { foo: 'bar' } }
          let(:att_ingester) { described_class.new(id, attributes, context: foo_context) }
          it "passes the value to the new attribute" do
            expect(att_ingester.raw_attributes['sort_title']).to eq 'bar'
          end
        end
        context "with a single-valued attribute" do
          context "with a single value" do
            let(:attributes) { { sort_title: 'foobar' } }
            it "passes the attribute" do
              expect(att_ingester.raw_attributes['sort_title']).to eq 'foobar'
            end
          end
          context "with multiple values" do
            let(:attributes) { { sort_title: ['foo', 'bar'] } }
            it "passes the attribute, with the final value only" do
              expect(att_ingester.raw_attributes['sort_title']).to eq 'bar'
            end
          end
        end
        context "with a multi-valued attribute" do
          context "with a single value" do
            let(:attributes) { { title: 'foobar' } }
            it "passes the attribute, array-wrapping the value" do
              expect(att_ingester.raw_attributes['title']).to eq ['foobar']
            end
          end
          context "with multiple values" do
            let(:attributes) { { title: ['foo', 'bar'] } }
            it "passes the attribute, with all values" do
              expect(att_ingester.raw_attributes['title']).to eq ['foo', 'bar']
            end
          end
        end
      end
    end
  end
end
