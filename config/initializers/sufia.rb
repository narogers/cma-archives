# Returns an array containing the vhost 'CoSign service' value and URL
Sufia.config do |config|

  config.fits_to_desc_mapping= {
    file_title: :title,
    file_author: :creator
  }

  # Exif to Dublin Core mappings
  config.exif_to_desc_mapping = {
    subject: :subject,
    hierarchicalSubject: :subject,
    personInImage: :subject,
    keywords: :subject,
    SourceFile: :source,
    sourcefile: :source,
    JobID: :identifier,
    headline: :abstract,
    description: :description,
    sublocation: :spatial,
    location: :spatial,
    DateTimeOriginal: :date_created,
    CreateDate: :date_created,
    datetimecreated: :date_created,
    DateTime: :date_modified,
    ModifyDate: :date_modified,
    datetimemodifed: :date_modified,
    # These are CMA specific fields
    'by-linetitle' => :photographer_title,
    AuthorsPosition: :photographer_title,
    'by-line' => :photographer,
    creator: :photographer,
    credit: :credit_line
  }

  config.max_days_between_audits = 7

  config.max_notifications_for_dashboard = 5

  config.cc_licenses = {
    'All rights reserved' => 'All rights reserved'
  }

  config.cc_licenses_reverse = Hash[*config.cc_licenses.to_a.flatten.reverse]

  config.resource_types = {
    "Image" => "Image",
    "Map or Cartographic Material" => "Map or Cartographic Material",
    "Poster" => "Poster",
    "Other" => "Other",
  }

  config.resource_types_to_schema = {
    "Image" => "http://schema.org/ImageObject",
    "Map or Cartographic Material" => "http://schema.org/Map",
    "Poster" => "http://schema.org/CreativeWork",
    "Other" => "http://schema.org/CreativeWork",
  }

  config.permission_levels = {
    "Choose Access"=>"none",
    "View/Download" => "read",
    "Edit" => "edit"
  }

  config.owner_permission_levels = {
    "Edit" => "edit"
  }

  config.queue = Sufia::Resque::Queue

  # Enable displaying usage statistics in the UI
  # Defaults to FALSE
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = false

  # Specify a Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # config.analytic_start_date = DateTime.new(2014,9,10)

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  config.temp_file_base = '/tmp/passenger'

  # Specify the form of hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  # config.enable_ffmpeg = true

  # Sufia uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  config.enable_noids = true

  # Specify a different template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Specify the prefix for Redis keys:
  config.redis_namespace = "sufia"

  # Specify the path to the file characterization tool:
  config.fits_path = "/opt/fits/fits/fits.sh"

  # Specify how many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  config.activity_to_show_default_seconds_since_now = 24*60*60

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014,9,10)
  #
  # Method of converting pids into URIs for storage in Fedora
  # config.translate_uri_to_id = lambda { |uri| uri.to_s.split('/')[-1] }
  # config.translate_id_to_uri = lambda { |id|
  #      "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{Sufia::Noid.treeify(id)}" }

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn "BrowseEverything is not installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end
  #config.enable_local_ingest = true
end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"
