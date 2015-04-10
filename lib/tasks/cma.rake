namespace :cma do
  namespace :batch do
	  require "#{Rails.root}/app/jobs/batch_ingest_job"

	  desc "Batch ingest content to CMA standards"
	  task :ingest, [:base_directory] do |t, args|
	  	puts Sufia.queue.default_queue_name
		# TODO : Invoke the batch ingest job for each
		#        batch.csv found underneath the root
		#        directory
    end
	end
end
