require 'csv'

class UpdateCollectionMetadataJob < ActiveFedoraIdBasedJob
  attr_accessor :csv_source
  
  def queue_name
    :batch_update
  end

  def initialize(csv_source)
    self.csv_source = File.expand_path(csv_source)
    @successful_updates = []
    @failed_updates = [] 
  end

  def run
    collections = CSV.read(csv_source, encoding: "UTF-8", headers: true, 
      header_converters: :symbol)
    collections.each_with_index do |collection, i|
      Resque.logger.info("[BATCH UPDATE] Updating #{collection[:name]} (#{i} of #{collections.size})")
      update_collection(collection)
    end

    log_updates
  end

  # Resolves the collection name to an ID so that you can batch update all of its
  # members
  def update_collection(collection)
    # Take the name out of the list of keys so that all that remains are fields to
    # be updated
    name = collection.delete(:name)
    name = name.last

    coll = Collection.where(title: name).first
 
    if (coll.present? and (coll.title == name))
      Resque.logger.info("[BATCH UPDATE] Processing #{coll.title}")
      update_and_save_metadata(coll, collection) 
      @successful_updates << name
    else
      Resque.logger.warn("[BATCH UPDATE] Could not locate #{name}")
      @failed_updates << name
    end
  end

  # The update process will respect any existing fields unless they already exist
  # in which case the deduping process will remove any extra instances. The only
  # exception is singular fields, which will be overwritten.
  def update_and_save_metadata(collection, metadata)
    fields = metadata.to_h.keys.sort
    collection.members.each do |gf|
      fields.each do |field|
        if gf[field].is_a? Array
          # Multivalued field
          gf[field] += [metadata[field]]
          gf[field].uniq!
        else 
          # Singular field
          gf[field] = metadata[field]
        end
      end

      # Commit the changes to the database
      if gf.save
        Resque.logger.info "[BATCH UPDATE] #{gf.title.first} (#{gf.id}) has been successfully updated"
      else
        Resque.logger.warn "[BATCH UPDATE] #{gf.title.first} (#{gf.id}) could not be updated"
      end
    end

    def log_updates
      Resque.logger.info "[BATCH UPDATES] The following collections were updated"
      @successful_updates.each do |coll|
        Resque.logger.info "[BATCH UPDATE] #{coll}"
      end

      Resque.logger.info "[BATCH UPDATE] The following collections could not be processed"
      @failed_updates.each do |coll|
        Resque.logger.info "[BATCH UPDATE] #{coll}"
      end


    end

  end
end
