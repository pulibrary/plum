namespace :state do
  desc "Migrate state from the state property to Sipity"
  task migrate: :environment do
    ['MultiVolumeWork', 'ScannedResource'].each do |model|
      ActiveFedora::SolrService.get("has_model_ssim:#{model}")['response']['docs'].each do |doc|
        puts doc['id']
        obj = ActiveFedora::Base.find(doc['id'])
        unless obj.workflow_state
          Workflow::InitializeState.call(obj, 'book_works', obj.state)
          obj.state = Vocab::FedoraResourceStatus.active
          obj.save!
        end
      end
    end
  end
end
