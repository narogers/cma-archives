module CMA
	module GenericFile
		module Derivatives
		  extend ActiveSupport::Concern

		  # Override the default MIME types in GenericFile::MimeTypes to
      # include DNG
      included do
      	include Sufia::GenericFile::Derivatives

      	makes_derivatives do |obj|
          logger.info("[DERIVATIVES] Preparing to convert a(n) #{obj.mime_type}")
    			case obj.mime_type
    			when *image_mime_types
    				obj.transform_file :content, { 
              thumbnail: { 
                format: 'jpg',    						
                size: '200x150>',
    						datastream: 'thumbnail'
    					}
    				}, processor: image_processor
          end
        end

        # The solution for tools constantly resetting the MIME type
        # to image/tiff is to instead check and see if the format
        # contains 'Digital Negative'
        def image_processor
	  is_raw_file? ? :raw_image : :image
        end 

        # Can be called as a before_save callback to reset the MIME
        # type for digital negatives (DNG)
        def verify_mime_type
          if is_raw_file?
            self.mime_type = "image/x-adobe-dng"
          end
        end

        # Returns true if the image is a Digital Negative
        #
        # By doing it this way any variants can be managed in a
        # single location that can supplemented as needed
        def is_raw_file?
          @raw_formats ||= ["Digital Negative", "DNG EXIF"]
          @raw_formats.each do |rf|
            return true if format_label.include? rf
          end

          # If you get here no matches were found
          return false
        end
      end
    end
  end
end

