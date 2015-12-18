# Implementation of the service for creating temporary files that
# assumes the bits are accessible on disk. 
#
# Instead of passing GenericFile.content pass the actual GenericFile so we can get at
# other methods like the import URL
class LocalTempfileService < Hydra::Derivatives::TempfileService
    # All we have to do is open the source file and copy its
    # contents into the temporary file before we yield
    def tempfile(&block)
        local_path = extract_path_from_uri(source_file.import_url)
        Resque.logger.info "[Hydra Derivatives] Using local copy from #{local_path}"
        Tempfile.open(filename_for_characterization) do |f|
            f.binmode
            source = File.open(local_path, "r")
            f.write(source.read)
            # We don't need the origin any more so release the bits
            source.close

            f.rewind
            yield(f)
        end
    end

    def extract_path_from_uri(uri)
        uri.sub!("file://", "")
        uri = File.expand_path(uri)
        
        return uri
    end
end
