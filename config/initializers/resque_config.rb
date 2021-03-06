config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Resque.redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true)

Resque.inline = Rails.env.test?
Resque.redis.namespace = "#{Sufia.config.redis_namespace}:#{Rails.env}"

# Capture all output at the INFO level or higher
Resque.logger = Logger.new("log/resque.log")
Resque.logger.level = Logger::INFO
