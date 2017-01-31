RSpec.shared_examples "structure persister" do |resource_symbol, presenter_factory|
  describe "#structure" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end
    let(:solr) { ActiveFedora.solr.conn }
    let(:resource) do
      r = FactoryGirl.build(resource_symbol)
      allow(r).to receive(:id).and_return("1")
      allow(r.list_source).to receive(:id).and_return("3")
      r
    end
    let(:file_set) do
      f = FactoryGirl.build(:file_set)
      allow(f).to receive(:id).and_return("2")
      f
    end
    before do
      resource.ordered_members << file_set
      solr.add file_set.to_solr.merge(ordered_by_ssim: [resource.id])
      solr.add resource.to_solr
      solr.add resource.list_source.to_solr
      solr.commit
    end
    it "sets @members" do
      get :structure, params: { id: "1" }

      expect(assigns(:members).map(&:id)).to eq ["2"]
    end
    it "sets @logical_order" do
      obj = double("logical order object")
      allow_any_instance_of(presenter_factory).to receive(:logical_order_object).and_return(obj)
      get :structure, params: { id: "1" }

      expect(assigns(:logical_order)).to eq obj
    end
  end

  describe "#save_structure" do
    let(:resource) { FactoryGirl.create(resource_symbol, user: user) }
    let(:file_set) { FactoryGirl.create(:file_set, user: user) }
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
      resource.ordered_members << file_set
      resource.save
    end
    let(:nodes) do
      [
        {
          "label": "Chapter 1",
          "nodes": [
            {
              "proxy": file_set.id
            }
          ]
        }
      ]
    end
    it "persists order" do
      post :save_structure, params: { nodes: nodes, id: resource.id, label: "TOP!" }

      expect(response.status).to eq 200
      expect(resource.reload.logical_order.order).to eq({ "label": "TOP!", "nodes": nodes }.with_indifferent_access)
    end
  end
end
