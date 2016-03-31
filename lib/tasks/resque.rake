# Load the Rails app all the time. See 
# https://github.com/resque/resque/wiki/FAQ for more details
require 'resque/pool'
require 'resque/pool/tasks'

namespace :resque do
	task :setup => :environment do
  	# Set up sufia jobs here?
	end

    task :status => :environment do
      pid_file = "#{Rails.root}/tmp/pids/resque-pool.pid" 
      if File.exists? pid_file
        pid = File.read pid_file
        print "Resque pool is active (PID #{pid})\n"
      else
        print "Resque pool is not running\n"
      end
    end

    # Cribbed from CLI examples at 
    # https://github.com/nevans/resque-pool/blob/master/lib/resque/pool/cli.rb 
    task :start => :environment do
      # Use a KILL option to hotswap the existing pool(s)
    end

    task :stop => :environment do
      # Kill by passing along a SIGQUIT
    end

  namespace :pool do
  	task :setup => :environment do
      ActiveRecord::Base.connection.disconnect!

  		Resque::Pool.after_prefork do |j|
    		ActiveRecord::Base.establish_connection
    		Resque.redis.client.reconnect
  		end
		end
	end
end
