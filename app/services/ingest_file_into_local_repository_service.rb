class IngestFileIntoLocalRepositoryService
  def self.ingest generic_file
    source = Addressable::URI.parse(generic_file.import_url).path
    if source.start_with? CMA.config["repository"]["root"]
      raise FileIngestError.new "Cannot ingest into repository from itself" 
    end  

    # TODO: Wrap this neatly in a begin / rescue block to catch 
    #       - Out of disk space
    #       - Permission denied
    #
    # TODO: Use generic_file.local_file instead of repeating code?
    pair = generic_file.id.scan(/..?/).first(4)
    destination = File.join(CMA.config["repository"]["root"], *pair, generic_file.id)
    FileUtils.mkdir_p File.dirname(destination)
 
    FileUtils.cp source, destination
    FileUtils.chmod 0640, destination
    FileUtils.chown CMA.config["repository"]["owner"],
      CMA.config["repository"]["group"],
      destination

    checksum = Digest::SHA1.file(destination).hexdigest
    Rails.logger.info "[INGEST FILE] Writing out SHA1 checksum for #{generic_file.id} to #{destination}.sha1"
    File.open("#{destination}.sha1", "w") do |sha1|
      sha1 << checksum
    end
  end
end

class FileIngestError < StandardError
end
