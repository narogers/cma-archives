# Audits the repository and reports any objects which cannot be found.
# This is helpful to run after restoring the LevelDB database after it has
# been corrupted as a method of identifying which things need to be repaired.
#
# Pair it with ActiveFedora::Base.reindex_everything for best results as 
# audit is not aware of thing that do not exist in Solr yet
namespace :cma do
  desc "Audit Solr index and update against Fedora"
  task :audit => :environment do
    healthy_records = []
    missing_records = []    
  
    gf_ids = ActiveFedora::SolrService.query("has_model_ssim: GenericFile", 
      {fl: "id", rows: GenericFile.count})
    gf_ids = gf_ids.map { |gf| gf["id"] }
    record_count = gf_ids.count.freeze

    gf_ids.each_with_index do |id, i|
      print "[#{id} #{i+1} / #{record_count}] Auditing #{id}\n"
      begin
        gf = GenericFile.find(id)
        # As long as we have content we can regenerate the other derivatives
        if gf.content.has_content?
          print "[#{id} #{i+1} / #{record_count}] Record appears healthy\n"
          healthy_records << id
        else
          print "[#{id} #{i+1} / #{record_count}] WARNING: content datastream may be missing\n"
        end
      rescue ActiveFedora::ObjectNotFoundError
        print "[#{id} #{i+1} / #{record_count}] WARNING: ID could not be found in Fedora\n"
        missing_records << id
      end
    end
  end

  # Lifted from https://github.com/avalonmediasystem/avalon/blob/develop/lib/tasks/avalon.rake#L138-L152
  desc "Reindex all objects"
  task :reindex, [:threads] => :environment do |t, args|
    descendants = ActiveFedora::Base.descendant_uris("#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}")
    descendants.shift
    Parallel.map(descendants, in_threads: args[:threads].to_i || 1) do |uri|
      begin
        ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(uri)).update_index
        puts "#{uri} reindexed"
      rescue => error
        puts "Error reindexing #{uri}"
        puts error.inspect
      end
    end
  end
end
