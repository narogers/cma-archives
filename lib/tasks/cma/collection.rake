namespace :cma do
    namespace :collection do
        desc "Batch update metadata for specific collections"
        task :update, [:csv] => :environment do |t, args|
          if args[:csv].present? and File.exists? args[:csv]
            print "Queuing #{args[:csv]} for processing. Check Resque logs for progress\n"
            Sufia.queue.push(UpdateCollectionMetadataJob.new(args[:csv]))
          else
            print "WARNING: Provide a valid CSV file to continue\n"
          end
        end

        desc "Reprocess EXIF metadata for all objects"
          task :extract_exif => :environment do
            query = "has_model_ssim:GenericFile"
            limits = {fl: "id, title_tesim", rows: GenericFile.count}
            solr_results = ActiveFedora::SolrService.query(query, limits)
        
            gf_ids = {}
            solr_results.map do |r| 
               gf_ids[r["id"]] = 
                  r["title_tesim"].nil? ? "<Undefined" : r["title_tesim"].first 
            end
        
            gf_ids.each do |id, title|
               puts "[#{id}] Processing #{title}\n"
               if not GenericFile.exists? id
                  puts "WARNING: Could not locate #{id} in Fedora"
                  next
               end
               extraction_job = ExtractExifMetadataJob.new(id)
               extraction_job.run
           end
       end
    end
end
