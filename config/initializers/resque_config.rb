require 'buffered_logger'

config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Resque.redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true)

Resque.inline = Rails.env.test?
Resque.redis.namespace = "#{Sufia.config.redis_namespace}:#{Rails.env}"

# Implement logging to help in tracing errors that may occur
# Approach is modified from information at
#  http://jademind.com/blog/posts/enable-immediate-log-messages-of-resque-workers/
Resque.logger = BufferedLogger.new(File.join(Rails.root, "log", "resque.log"))
Resque.logger.level = Logger::INFO
