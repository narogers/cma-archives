require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CMAydra
  class Application < Rails::Application
    config.generators do |g|
      g.test_framework :rspec, :spec => true
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
   
    # Exif to Dublin Core mappings
    # WIP: Not a long term solution; more of a bandaid fix
    config.exif = OpenStruct.new
    config.exif.field_mappings = {
      Subject: :subject,
      HierarchicalSubject: :subject,
      PersonInImage: :subject,
      Keywords: :subject,
      SourceFile: :source,
      JobID: :identifier,
      Headline: :abstract,
      Description: :description,
      Sublocation: :spatial,
      Location: :spatial,
      DateTimeOriginal: :date_created,
      CreateDate: :date_created,
      DateTimeCreated: :date_created,
      DateTime: :date_modified,
      ModifyDate: :date_modified,
      DateTimeModifed: :date_modified,
      # These are CMA specific fields
      'by-linetitle' => :photographer_title,
      AuthorsPosition: :photographer_title,
      'by-line' => :photographer,
      Creator: :photographer,
      Credit: :credit_line
    }
    # Default fields for images
    config.exif.default_metadata = {
      rights: "Copyright, The Cleveland Museum of Art",
      contributor: "Cleveland Museum of Art",
      language: "en",
      resource_type: "Image"
    }

    config.characterization_service_limit = 500*(2**20)
  end
end
