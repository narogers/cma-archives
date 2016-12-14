class LocalFileUrlService
  include Rails.application.routes.mounted_helpers
  
  def download_url generic_file
    sufia.download_url generic_file, Rails.application.config.default_url_options
  end
end
