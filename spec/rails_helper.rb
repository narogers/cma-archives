require 'simplecov'
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rspec'
require 'active_fedora/cleaner'
require 'database_cleaner'
require 'factory_girl'
require 'devise'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.before :suite do
    ActiveFedora::Cleaner.clean!
  end

  config.before :each do |test|
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start  
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.include Devise::TestHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods

  config.include Warden::Test::Helpers, type: :feature
  Warden.test_mode!
end
