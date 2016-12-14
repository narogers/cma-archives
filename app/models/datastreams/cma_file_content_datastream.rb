# Determines which type of resource is present in the stream (local or Fedora)
# and delegates all calls to that resource
class CMAFileContentDatastream < FileContentDatastream
  attr :container

  def container
    @container ||= GenericFile.load_instance_from_solr id.split("/").first
  end
    
  def stream(range = nil)
    local_file? ? LocalFileBody.new(container.local_file) : super
  end

  private
    def retrieve_content
      local_file? ? File.binread(@container.local_file) : ldp_source.get.body
    end

    def local_file?
      File.exists? container.local_file
    end
end

