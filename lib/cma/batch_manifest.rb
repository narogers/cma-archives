require 'csv'

class BatchManifest
  include Sufia::Engine.routes.url_helpers
  attr :batches, :base_path

  # :nocov:
  def queue_name
    :batch_manifest
  end
  # :nocov:

  def initialize base_path
    @base_path = File.expand_path base_path
    @batch_manifests = Dir.glob "#{base_path}/**/batch.csv"
  end

  def generate
    @batches = read_batches
    
    timestamp = Time.now.strftime("%Y%m%d%H%M");
    file = "#{Rails.root}/log/reports/batchManifest.#{timestamp}.csv"

    CSV.open(file, "w") do |csv|
      write_headers csv
      generate_manifest csv
    end

    file
  end

  def read_batches
    batches = {}
    @batch_manifests.each do |csv|
      csv = CSV.read(csv)
      collection = csv[0].first
      files = csv[6, csv.length].sort!

      batches[collection] ||= []
      batches[collection] += files.map { |f| f[0] }
    end

    batches
  end

  def write_headers output
    output << [@base_path]
    output << [Time.now.strftime("%B %d, %Y %H:%M")]
    output << []
    output << [:file, :id, :collection, :batch, :fixity, :uri]
  end

  def generate_manifest output
    @batches.each do |coll_title, batch|
      collection = Collection.where("title_tesim:\"#{coll_title}\"")
      if collection.empty?
        logger.warn "[BATCH MANIFEST] Could not locate collection named #{coll_title}"
      else 
        collection = collection.first
        collection.members.each do |file|
          if batch.include? file.label
            options = Rails.application.config.default_url_options
            options[:id] = file.id
    
            uri = generic_file_url(options)
            batch_id = file.batch.present? ? file.batch.id : "N/A" 
            fixity = file.content.has_content? ? file.content.checksum : nil
            output << [file.id, file.label, collection.title, batch_id, fixity, uri]
            batch -= [file.label] 
          end
        end
      end

      batch.each do |missing_file|
        output << [nil, missing_file, coll_title, nil, nil, nil]
      end
    end
  end

  def logger
    Rails.logger
  end
end
