include Rails.application.routes.url_helpers

desc "Ingest one or more METS files"
task export_cicognara: :environment do
  c = (Collection.where(title: 'Bibliotheca Cicognara') || []).first
  abort "No collection found with title 'Bibliotheca Cicognara'" unless c

  CSV do |csv|
    csv << CicognaraCSV.headers
    CicognaraCSV.values(c).each do |row|
      csv << row
    end
  end
end
