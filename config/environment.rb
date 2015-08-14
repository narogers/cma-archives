# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Silence deprecation warnings when running in production to keep down
# log size
::ActiveSupport::Deprecation.silenced = true if Rails.env.development?
