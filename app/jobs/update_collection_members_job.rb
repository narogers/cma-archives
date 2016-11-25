# Batch updates the metadata for members of a collection 
require 'csv'

class UpdateCollectionMembersJob < ActiveFedoraIdBasedJob
  attr_accessor :csv_source
  
  # :nocov:
  def queue_name
    :batch_update
  end
  # :nocov:

  def initialize(csv_source)
    self.csv_source = File.expand_path(csv_source)
    @successful_updates = []
    @failed_updates = [] 
  end

  def run
    collections = CSV.read(csv_source, encoding: "UTF-8", headers: true, 
      header_converters: :symbol)
    collections.each_with_index do |collection, i|
      log_message("Updating #{collection[:name]} (#{i} of #{collections.size})")
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
    # Because the name may come in many forms we must use something like titlecase to help
    # account for variations
    name = name.last.titleize
    
    # Due to the way that batches are handled a collection may appear multiple times. Presume
    # that if it has already been processed it is safe to skip any duplicates
    if (@successful_updates.include?(name) or 
        @failed_updates.include?(name))
      log_message("Skipping duplicate collection entry")
      return
    end

    coll = Collection.where(title: name).first
 
    if (coll.present? and (coll.title == name))
      log_message("Processing #{coll.title}")
      update_and_save_metadata(coll, collection) 
      @successful_updates << name
    else
      log_message("Could not locate #{name}", Logger::WARN)
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
        log_message("#{gf.title.first} (#{gf.id}) has been successfully updated")
      else
        log_message("#{gf.title.first} (#{gf.id}) could not be updated", Logger::WARN)
      end
    end
  end
    
  def log_updates
    log_message("The following collections were updated")
    log_message(@successful_updates.sort.join("\n"))

    log_message("The following collections could not be processed")
    log_message(@failed_updates.sort.join("\n"))
  end

  def log_message(message, level = Logger::INFO)
    Rails.logger.log(level, "[BATCH UPDATE] #{message}")
  end
end
