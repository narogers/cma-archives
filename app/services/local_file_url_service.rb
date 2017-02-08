module LocalFileUrlService
  def self.download_url generic_file
    Sufia::Engine.routes.url_helpers.download_url generic_file, 
      Rails.application.config.default_url_options
  end
end
