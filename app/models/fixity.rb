class Fixity
  attr_accessor :file, :local, :remote

  def initialize(id)
    @file = GenericFile.load_instance_from_solr(id)
    @local_digest = nil
    @remote_digest = nil
  end

  def remote
    begin
      @remote_digest ||= CMA::FixityService.new(@file.id).fixity.first
    rescue Ldp::NotFound
      Rails.logger.warn "[FIXITY] Could not resolve fixity for #{@file.id}"
      @remote_digest = false
    end
  end

  def local
    if @local_digest.nil?
      path = @file.import_url.sub("file://", "")
      if File.exists? path
        @local_digest = Digest::SHA1.file(path).hexdigest
      else
        Rails.logger.warn "[FIXITY] Cannot calculate SHA1 digest for file at #{path}"
        @local_digest = false
      end
    end

    @local_digest 
  end

  def equal?
    @local_digest != false && (@local_digest == @remote_digest)
  end
end
