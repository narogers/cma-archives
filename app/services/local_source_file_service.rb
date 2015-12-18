# Override the source file service to see if the resource has a local version of the file
# before you go to Fedora. This only works with :import_url and the Sufia code base and not
# meant as a generalized solution
    class LocalSourceFileService
        def self.call(object, source_name, &block) 
            # This is an ugly hack to get things working by returning a hash. Ultimately
            # the logic should be reworked to be far less janky but time is money
            if has_local_version?(object)
                {content: object.import_url.sub("file://", "")}
            else
                object.send(source_name)
            end
        end

        protected

        def self.has_local_version?(object)
            has_local_version = false
            if ((object.respond_to? :import_url) &&
                 object.import_url.present?)
                has_local_version = validate_path(object.import_url)
            end

            return has_local_version
        end

        def self.validate_path(object_uri)
            return false unless object_uri.starts_with? "file://"
            # Since at this point we know that it is a local path we can
            # proceed with abandon
            local_path = object_uri.sub("file://", "")
            local_path = File.expand_path(local_path)
            return File.exists? local_path
        end
    end

