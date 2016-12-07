class LocalFileBody 
  attr_reader :path, :headers
  
  def initialize(path)
    @path = path
    @headers = headers
  end

  def each
    File.open(path, "rb") do |file|
      yield file.read
    end
  end
end
