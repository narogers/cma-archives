# Load the Rails app all the time. See 
# https://github.com/resque/resque/wiki/FAQ for more details
require 'resque/pool'
require 'resque/pool/tasks'

namespace :resque do
	task :setup => :environment do
  	# Set up sufia jobs here?
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
