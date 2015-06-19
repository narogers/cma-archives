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
    				}, processor: get_image_processor_for(obj)
          end
        end

        # The solution for tools constantly resetting the MIME type
        # to image/tiff is to instead check and see if the format
        # contains 'Digital Negative'
        def get_image_processor_for(image)
          case image
            # Put nil first to prevent errors later on with the
            # format label field
            when nil
              nil
            when image.format_label.include?("Digital Negative")
              :raw_image
            else
              :image
          end
        end 
      end
    end
  end
end

