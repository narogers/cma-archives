# Extension of FileContentDatastream with a small tweak that looks on local disk before
# going to Fedora to help with performance. To be sure the files are the same it verifies
# that the sizes are the same. In any conflicts precendence goes to the remote copy
class CMAFileContentDatastream < FileContentDatastream
  # Cache the URL that the file originated from for later use
  #
  # TODO: Figure out how to get a reference to the parent so you do not need this variable
  def local_path
    @local_path ||= nil
  end

  def local_path=(path)
    @local_path = path
  end

  private
    def retrieve_content
      if is_cached_locally?
        content = File.open(@local_path, "r") do |f|
            f.binmode
            f.read
        end

        content
      else
        ldp_source.get.body
      end
    end

    def is_cached_locally?
      return ((@local_path.present?) and
              File.exists? @local_path and 
              (File.size(@local_path) == size))
    end
end

