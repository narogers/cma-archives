source 'https://rubygems.org'

# Use dotenv to manage settings instead of fiddling with things across
# lots of files
gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2', group: :production

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

# Use Unicorn as the app server
# gem 'unicorn'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger', '~> 0.1.0'
  gem 'highline'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

#gem 'sufia', '~> 6.0'
gem "sufia", github: 'narogers/sufia' 
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'
#gem 'rsolr'
#gem 'browse-everything', github: 'narogers/browse-everything'
# Use a custom version of hydra-derivatives with a patch until
# RAW image support is baked into the core gem
gem 'hydra-derivatives', github: 'narogers/hydra-derivatives', branch: 'raw-processor'
gem 'mini_exiftool'

gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise_ldap_authenticatable'

group :development, :test do
  gem 'rspec-rails'
  gem 'jettywrapper'
end

# Gems for development - not really needed or welcome in production
# unless there are major problems
gem 'pry'
gem 'pry-rails'
gem 'pry-byebug'

gem 'rsolr', '~> 1.0.6'
