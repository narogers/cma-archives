namespace :cma do
  namespace :batch do
	  desc "Batch ingest content according to CMA standards"
	  task :ingest, [:base_directory] => :environment do |t, args|
	  	full_path = File.expand_path(args[:base_directory])
	  	batches = FileList.new("#{full_path}/**/batch.csv")
	  	
	  	batches.each do |batch|
	  		(directory, batch_file) = File.split(batch)
	  		puts "Processing directory #{directory}"
	  		Sufia.queue.push(BatchIngestJob.new(batch))
	  	end
    end
	end
end
