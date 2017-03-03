namespace :reindex do
  desc "Update remote metadata"
  task remote: :environment do
    models = ['MultiVolumeWork', 'ScannedResource']
    models.each do |model|
      ActiveFedora::SolrService.query("has_model_ssim:#{model}", fl: "id", rows: 10000).map{|x| x["id"]}.each do |id|
        puts "#{id} (#{model})"
        obj = ActiveFedora::Base.find(id)
        if obj.source_metadata_identifier
          obj.apply_remote_metadata
          obj.save
        end
      end
    end
  end

  desc "Update Solr metadata"
  task solr: :environment do
    models = ['MultiVolumeWork', 'ScannedResource']
    models.each do |model|
      ActiveFedora::SolrService.query("has_model_ssim:#{model}", fl: "id", rows: 10000).map{|x| x["id"]}.each do |id|
        puts "#{id} (#{model})"
        obj = ActiveFedora::Base.find(id)
        obj.update_index
      end
    end
  end
end
