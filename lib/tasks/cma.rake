namespace :cma do
    namespace :batch do
        desc "Batch ingest content according to CMA standards"
        task :ingest, [:base_directory] => :environment do |t, args|
            full_path = File.expand_path(args[:base_directory])
            batches = FileList.new("#{full_path}/**/batch.csv")
	
            batches.each do |batch|
              (directory, batch_file) = File.split(batch)
              puts "Queuing #{directory} for ingest"
              Sufia.queue.push(BatchIngestJob.new(batch))
	  	    end
        end

        desc "Batch update collection metadata"
        task :update_collections, [:csv] => :environment do |t, args|
          # TODO : Fill in the gaps here
        end
    end

    desc "Report failures in the background jobs"
    task :failures => :environment do 
        # TODO: Make this more configurable and not hard coded into the
        #       rake task
        gf_queues = ["audit", "characterize", "derivatives", "exif_metadata"]

        fails = Resque::Failure.all(0, Resque::Failure.count)
        fails.map do |f|
            puts "#{f['worker']}"
            puts "=" * f['worker'].length
            puts "QUEUE: #{f['queue']}"
            puts "TIMESTAMP: #{f['failed_at']}"
            puts "EXCEPTION: #{f['exception']}"
            puts "ERROR: #{f['error']}"
    
            next unless gf_queues.include? f['queue']

            pid = Base64.decode64(f['payload']['args'].first).match(/\w{2}\d{2}\w{2}\d{2}\w/).to_s
            gf = GenericFile.load_instance_from_solr(pid)
            puts "ID: #{gf.id}"
            puts "SOURCE: #{gf.import_url}"
            puts
        end
    end

    desc "Reprocess EXIF metadata for all objects"
    task :extract_exif_data => :environment do
        query = "has_model_ssim:GenericFile"
        limits = {fl: "id, title_tesim", rows: GenericFile.count}
        solr_results = ActiveFedora::SolrService.query(query, limits)
        
        gf_ids = {}
        solr_results.map do |r| 
            gf_ids[r["id"]] = 
              r["title_tesim"].nil? ? 
                "<Undefined" :
                r["title_tesim"].first 
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
