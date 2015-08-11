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
end
