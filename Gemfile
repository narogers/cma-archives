source 'https://rubygems.org'

gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
group :staging, :production do
  gem 'mysql2', '~> 0.4'
end
gem 'font-awesome-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
# Pin sprocket-rails to the 2.3 branch until some bugs affecting tiny-mce
# are worked out
gem 'sprockets-rails', '~> 2.3'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development, :production do
  gem 'capistrano', '~> 3.7'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger', '~> 0.2'
  gem 'capistrano-rbenv'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'highline'
  gem 'fcrepo_wrapper'
  gem 'solr_wrapper'
end

gem 'sufia', '~> 6.7.0'
gem 'kaminari', git: 'https://github.com/jcoyne/kaminari', branch: 'sufia'
gem 'parallel'

gem 'active-fedora', '~> 9'
gem 'rsolr', '~> 1.0.6'
gem 'blacklight_range_limit'

# Once Sufia's references are updated use v2.0 instead
gem 'mini_exiftool'
gem 'exiftool'

gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise_ldap_authenticatable'

group :development do
  gem 'any_login'
  gem 'web-console', '~> 2.0'
  gem 'ruby-prof'
  gem 'awesome_print'
  gem 'meta_request'
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

# Enhance background job support and logging of jobs
gem 'resque-pool', git: "https://github.com/nevans/resque-pool", branch: "master"
gem 'resque-status' 
gem 'resque-dynamic-queues'
gem 'resque-logger'

# Gems for development - not really needed or welcome in production
# unless there are major problems
gem 'pry'
gem 'pry-rails'

# For performace in production
group :production do
  gem 'dalli'
end
