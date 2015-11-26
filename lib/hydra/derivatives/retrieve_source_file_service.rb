# Override the source file service to see if the resource has a local version of the file
# before you go to Fedora. This only works with :import_url and the Sufia code base and not
# meant as a generalized solution
module Hydra::Derivatives
    class RetrieveSourceFileService
        def self.call(object, options, &block) 
            # Default to the method
            source_name = options.fetch(:source)
            # But override it if :import_url is available and set
            if (object.respond_to? :import_url &&
                object.import_url.present?)
                source_name = extract_path_from_uri(object.import_url, source_name)
            end
            
            # If the source is a symbol assume it is a reference to a method and fall
            # back. Otherwise point Hydra::Derivatives at the temporary file
            case source_name
                when Symbol
                    Hydra::Derivatives::TempfileService.create(object.send(source_name), &block)
                when String
                    Hydra::Derivatives::TempfileService.create(source_name, &block)
            end
        end

        protected

        # Extracts the local path from the URI and then checks to see if anything exists
        # there. If not it allows for falling back to the source
        def extract_path_from_uri(path, default_path)
            if (path.starts_with? "file://")
                path.sub!("file://", "")
                path = File.expand_path(path)
                path = File.exists?(path) ? path : default_path
                return path
            else
                return default_path
            end
        end
    end
end

