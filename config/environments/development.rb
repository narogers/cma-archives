Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.log_tags = [ :uuid ]
  config.log_level = :debug
  config.logger = Logger.new(Rails.root.join("log", Rails.env + ".log"))

  # Reroute STDERR to a log file in the same directory for easier
  # troubleshooting instead of having it swallowed by the Apache
  # logs
  Deprecation.default_deprecation_behavior = :silence

  # Suppress whiny output from the web console
  #config.web_console.whiny_requests = false
  #config.web_console.whitelisted_ips = "192.168.56.1"
  if defined? ::BetterErrors
    ::BetterErrors::Middleware.allow_ip! '192.168.56.0/24'
  end

  # Default hosts for services
  config.default_url_options = { host: "192.168.56.105", port: 82 }
  config.action_mailer.default_url_options = config.default_url_options
end
