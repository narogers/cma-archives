require 'app/jobs/batch_ingest_job'

namespace :cma do
  namespace :batch do
	  desc "Batch ingest content to CMA standards"
	  task :ingest [:base_directory, :collection] do |t, args|
	  	puts Sufia.resque.default_queue_name
	  	#Sufia.resque.BatchIngestJob.new(
    end
	end
end