namespace :pudl do
  desc "Output mapping from PUDL to Plum derivatives"
  task map: :environment do
    q = "has_model_ssim:FileSet"
    pages = (ActiveFedora::SolrService.count(q) / 1000) + 1
    fl = ['id', 'replaces_ssim']
    (0..pages).each do |p|
      ActiveFedora::SolrService.query(q, fl: fl, rows: 1000, start: "#{p}000").each do |doc|
        if doc['replaces_ssim']
          pudl = URI.escape(doc['replaces_ssim'].first.gsub(/.*:/, '').gsub(/\.tif$/, ''), '/')
          plum = URI.escape(doc['id'].scan(/..?/).join('/'), '/')
          puts "#{pudl}.jp2 plum_prod/#{plum}-intermediate_file.jp2"
        end
      end
    end
  end
end
