source 'https://rubygems.org'

gem 'rails', '4.2.7'
gem 'sufia', '~> 6.7.0'
gem 'kaminari', git: 'https://github.com/jcoyne/kaminari', branch: 'sufia'
gem 'active-fedora', '~> 9'
gem 'rsolr', '~> 1.0.6'
gem 'blacklight_range_limit'

gem 'dotenv-rails'

# Database management
gem 'sqlite3'
gem 'mysql2', '~> 0.4'

# Interface (jQuery, SASS, etc)
gem 'jquery-rails'
gem 'font-awesome-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'turbolinks'

# Image metadata extraction
gem 'mini_exiftool'
gem 'exiftool'
gem 'ruby-vips'

gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
# Pin sprocket-rails to the 2.3 branch until some bugs affecting tiny-mce
# are worked out
gem 'sprockets-rails', '~> 2.3'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'parallel'
gem 'bcrypt', '~> 3.1.7'

# Authentication related gems
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise_ldap_authenticatable'

# Background processing support
gem 'resque-pool', git: "https://github.com/nevans/resque-pool", branch: "master"
gem 'resque-status' 
gem 'resque-dynamic-queues'
gem 'resque-logger'

group :development, :production do
  gem 'capistrano', '~> 3.7'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger', '~> 0.2'
  gem 'capistrano-rbenv'
  gem 'capistrano-rails-console'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'highline'
  gem 'fcrepo_wrapper'
  gem 'solr_wrapper'
end

group :development do
  gem 'pry'
  gem 'pry-rails'
  gem 'any_login'
  gem 'web-console', '~> 2.0'
  gem 'awesome_print'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do 
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4'
  gem 'faker'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'webmock'
end

# For performance in production
group :production do
  gem 'dalli'
end
