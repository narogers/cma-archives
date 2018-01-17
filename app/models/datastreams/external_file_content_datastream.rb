class ExternalFileContentDatastream < FileContentDatastream
  # uri should be a path such as file:///home/foo/repository/12/34/56/78/123456789
  attr_accessor :path

  def initialize uri, *args
    @path = uri.start_with?("file://") ? uri.sub("file://", "") : uri  
  end

  def has_content?
    File.exists? path
  end

  # This implementation does not support versioning
  def has_versions?
    false
  end

  # TODO: Fix handle leak by closing at some point
  def stream(range = nil)
    File.open(path, "rb")
  end
end
