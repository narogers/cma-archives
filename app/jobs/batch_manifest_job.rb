require 'csv'

class BatchManifestJob
  include Rails.application.routes.url_helpers

  attr_reader :batch, :file

  # :nocov:
  def queue_name
    :batch_manifest
  end
  # :nocov:

  def initialize id
    @batch = Batch.find id if Batch.exists? id

    @file = @batch.title.first.gsub(" ", "_")
    @file += ".manifest.csv"
  end

  def run
   csv = CSV.open(file, "w")

    csv << [@batch.title.first]
    # TODO: Do not use a hard coded host value
    csv << [catalog_index_url(host: "archive.clevelandart.org",
      q: @batch.id,
      search_field: "batch")]
    csv << [@batch.create_date.strftime("%B %-d, %Y %k:%m:%S")]
    csv << []

    generate_manifest csv

    csv.close

    @file 
  end

  def generate_manifest csv_file
    csv_file << [:file, :local_path, :fedora_uri, :local_checksum, :remote_checksum]
    @batch.generic_files.each do |gf|
      fixity = Fixity.new gf.id
      csv_file << [gf.label, gf.import_url, gf.uri, fixity.local, fixity.remote]
    end
  end
end
