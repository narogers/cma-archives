module CMA
	module GenericFile
		module TempfileService
			extend ActiveSupport::Concern

      included do
        # Temporary file name is based on the file extension and
        # defined here so it can be called from many jobs that 
        # access the GenericFile
        #
        # Override if you need to fix it to something else
        def tempfile_name
          mime_info = MIME::Types[mime_type]
          file_name = id
          file_name += ".#{mime_info.first.extensions.first}" unless mime_info.blank?

          file_name
        end
      end
		end
	end
end