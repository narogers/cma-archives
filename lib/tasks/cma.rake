namespace :cma do
  namespace :batch do
	  desc "Batch ingest content according to CMA standards"
	  task :ingest, [:base_directory] => :environment do |t, args|
	  	root = Dir.open(args[:base_directory])
	  	base_path = args[:base_directory]
	  	root.each do |handle|
	  		if handle.eql?("batch.csv")
	  			puts "Processing #{base_path}"
	  			puts "Using batch file #{base_path}/#{handle}"
	  			Sufia.queue.push(BatchIngestJob.new("#{base_path}/#{handle}"))
	  			break
	  		end
	  		if File.directory?(File.expand_path("#{base_path}/#{handle}"))
	  			# Recurse down child directories
	  			puts "TODO: Recursive behavior"
	  		end
	  	end

    end
	end
end
