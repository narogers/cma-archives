namespace :cma do
  namespace :derivative do
    desc "Update derivative from an external source"
    task :update, [:id, :derivative, :path] => :environment do |t, args| 
      if (args[:path].nil?) or
         (not File.exists? File.expand_path(args[:path]))
        abort "WARNING: #{args[:path]} could not be found on disk"
      end

      if "content" == args[:derivative]
        abort "WARNING: The original resource should be replaced through an ingest process"
      end
        
      ImportDerivativeJob.new(args[:id], args[:derivative], args[:path]).run
    end

    desc "Regenerate derivatives from the original image"
    task :refresh, [:id, :background] => :environment do |t, args|
      enqueue_flag = args[:background].nil? ? false : args[:background]

      job = CreateDerivativesJob.new(args[:id])
      if args[:background]
        puts "Queueing derivative generation in the background"
        Sufia.queue.push(job)
      else
        job.run 
      end    
    end
  end
end
