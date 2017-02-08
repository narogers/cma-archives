module CMA
  class ExternalChecksum
    attr_reader :uri, :value, :algorithm

    def initialize file
      return unless File.exists? file.container.local_file

      @value = Digest::SHA1.file("#{file.container.local_file}").hexdigest
      @algorithm = 'sha1'
      @uri = "urn:#{@algorithm}:#{@value}"
    end
  end
end
