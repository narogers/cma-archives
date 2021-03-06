set :rails_env, :staging
set :branch, ENV.fetch("CAPISTRANO_BRANCH", "master")
set :deploy_to, "/var/www/sites/arapp-test/apps/cma-archives/"
set :log_level, :info

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server 'arapp-test.clevelandart.org', user: 'railsapp', roles: %w{app db web workers}

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.
fetch(:default_env).merge!(rails_env: :staging)
set :passenger_restart_with_touch, true
