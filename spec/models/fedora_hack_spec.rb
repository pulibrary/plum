require 'rails_helper'
require 'open-uri'

RSpec.describe HackyConnection do
  it "works" do
    child = FactoryGirl.create(:scanned_resource)
    parent = FactoryGirl.build(:scanned_resource)
    parent.author = [child.rdf_subject]
    parent.save

    content = open(parent.rdf_subject).read
    expect(parent.author_ids).to eq [child.rdf_subject]
    expect(content).to include child.uri.to_s.gsub("http://localhost:8986/rest/", "http://fake.com/")
  end

  it "works for children" do
    child = FactoryGirl.create(:scanned_resource)
    parent = FactoryGirl.build(:scanned_resource)
    parent.ordered_members << child
    parent.save

    content = open("#{parent.rdf_subject}/list_source").read
    expect(content).to include child.uri.to_s.gsub("http://localhost:8986/rest/", "http://fake.com/")
    expect(parent.reload.ordered_members).to eq [child]
  end

  it "can do updates" do
    child = FactoryGirl.create(:scanned_resource)
    child_2 = FactoryGirl.create(:scanned_resource)
    parent = FactoryGirl.build(:scanned_resource)
    parent.ordered_members << child
    parent.save

    expect(parent.reload.ordered_members).to eq [child]
    parent.ordered_members = [child_2]
    parent.save
    expect(parent.reload.ordered_members).to eq [child_2]
    content = open("#{parent.rdf_subject}/list_source").read
    expect(content).to include child_2.uri.to_s.gsub("http://localhost:8986/rest/", "http://fake.com/")
  end
end
