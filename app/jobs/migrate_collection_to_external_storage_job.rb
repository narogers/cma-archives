# Deletes old versions of the resource and copies them from internal
# Fedora storage to an external location. If all objects already exist in
# the external storage no action is taken
class MigrateCollectionToExternalStorageJob 
  attr :collection

  def initialize collection_id
    @collection ||= Collection.load_instance_from_solr collection_id
  end

  def queue_name
    :migrate
  end

  def run
    collection.members.each_with_index do |gf|
      next if File.exists? gf.local_file

      import_path = File.expand_path gf.import_url.gsub("file://", "")
      if File.exists? import_path
        migrate_content gf
      else
        create_temporary_file gf
      end
    end
  end

  def create_temporary_file generic_file
    original_path = generic_file.import_url.gsub("file://", "")
    if File.exists? original_path
      logger.warn "[MIGRATE #{generic_file.id}] File already exists at #{original_path}"
    else 
      Hydra::Derivatives::TempfileService.create(generic_file.content) do |tmp_file|
        logger.info "[MIGRATE #{generic_file.id}] Writing temporary file to #{tmp_file.path}"
        begin 
          generic_file.import_url = "file://#{tmp_file.path}"
          generic_file.save

          migrate_content generic_file
        ensure
          generic_file.import_url = "file://#{original_path}"
          generic_file.save
        end
      end
    end

    return original_path
  end

  def migrate_content gf
    if gf.content.versions.all.count > 0
      logger.info "[MIGRATE #{gf.id}] Removing expired versions"
      begin
        gf.content.delete(eradicate: true)
      rescue Ldp::Gone
        # This is not advised as general practice but is used to clean up
        # partially migrated objects
        uri = gf.content.uri + "/fcr:tombstone"
        logger.warn "[MIGRATE #{gf.id}] Removing tombstone from Fedora at #{uri}"
        ActiveFedora.fedora.connection.delete(uri)
      end
    end
      
    logger.info "[MIGRATE #{gf.id}] Moving content to external storage"
    IngestLocalFileJob.new(gf.id).run
  end

  # WIP
  def logger
    Rails.logger
  end
end
