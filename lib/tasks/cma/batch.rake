namespace :cma do
    namespace :batch do
        desc "Batch ingest content"
        task :ingest, [:base_directory] => :environment do |t, args|
            full_path = File.expand_path(args[:base_directory])
            csv_files = FileList.new("#{full_path}/**/batch.csv")
            batch = Batch.create(
              title: ["Batch #{DateTime.now.strftime("%Y.%m.%d.%H%M")}"])
   	
            csv_files.each do |path|
              directory = File.split(path)[0]
              puts "Queuing #{directory} for ingest\n"
              Sufia.queue.push BatchIngestJob.new(path, batch.id)
	  	    end
        end

        desc "Batch update metadata"
        task :update, [:base_directory] => :environment do |t, args|
          full_path = File.expand_path(args[:base_directory])
          csv_files = FileList.new("#{full_path}/**/batch.csv")
          csv_files.each do |path|
            directory = File.split(path)[0]
            puts "Batch updating #{directory}\n"
            Sufia.queue.push BatchUpdateJob.new path
          end
        end

        desc "Report failures in the background jobs"
        task :failures => :environment do 
            # TODO: Make this more configurable and not hard coded into the
            #       rake task
            gf_queues = ["audit", "characterize", "derivatives", "exif_metadata", "import"]

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
                puts "SOURCE: #{gf.import_url}\n"
            end
        end
    end
end
