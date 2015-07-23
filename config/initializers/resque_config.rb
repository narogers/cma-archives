config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
Resque.redis = Redis.new(host: config[:host], port: config[:port], thread_safe: true)

Resque.inline = Rails.env.test?
Resque.redis.namespace = "#{Sufia.config.redis_namespace}:#{Rails.env}"

# Use resque-logger to break down messages by queue for easier and faster
# troubleshooting
Resque.logger_config = {
	folder: File.join(Rails.root, 'log'),
	class_name: Logger,
	level: Logger::INFO,
}
