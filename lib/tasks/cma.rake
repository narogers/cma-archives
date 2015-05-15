namespace :cma do
  namespace :batch do
	  desc "Batch ingest content according to CMA standards"
	  task :ingest, [:base_directory] => :environment do |t, args|
	  	puts Sufia.queue.default_queue_name
		# TODO : Invoke the batch ingest job for each
		#        batch.csv found underneath the root
		#        directory
    end
	end
end
