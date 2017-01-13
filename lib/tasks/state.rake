namespace :state do
  desc "Migrate state from the state property to Sipity"
  task migrate: :environment do
    (MultiVolumeWork.all && ScannedResource.all).each do |r|
      puts r.id
      Workflow::InitializeState.call(r, 'book_works', r.state) unless r.workflow_state
    end
  end
end
