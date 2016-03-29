source 'https://rubygems.org'

# Use dotenv to manage settings instead of fiddling with things across
# lots of files
gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2', '~> 0.3.13', group: :production

# Use Font Awesome icon set
gem 'font-awesome-rails'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger', '~> 0.2'
  gem 'highline'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

gem 'sufia', '~> 6.6'
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'

#gem 'browse-everything', github: 'narogers/browse-everything'
# Peg to this version to avoid any future changes as PCDM Implementation
# continues. This code has the RAW fix merged into the main development
# branch
gem 'hydra-derivatives', github: 'projecthydra/hydra-derivatives', ref: 'cc031e7'
gem 'active-fedora', '9.10.4'

# Once Sufia's references are updated use v2.0 instead
#gem 'hydra-derivatives', '~> 2.0'
gem 'mini_exiftool'

gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise_ldap_authenticatable'

group :development do
  gem 'any_login'
end

group :test do 
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4'
  gem 'rspec-rails'
  gem 'simplecov', require: false
end

# Enhance background job support and logging of jobs
gem 'resque-status' 
gem 'resque-dynamic-queues'
gem 'resque-logger'

# Gems for development - not really needed or welcome in production
# unless there are major problems
gem 'pry'
gem 'pry-rails'
gem 'pry-byebug'

gem 'rsolr', '~> 1.0.6'

# Pin sprocket-rails to the 2.3 branch until some bugs affecting tiny-mce
# are worked out
gem 'sprockets-rails', '~> 2.3'
