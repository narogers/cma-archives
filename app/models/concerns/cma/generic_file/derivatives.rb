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
    				}
    			when *raw_image_mime_types
    				obj.transform_file :content, { 
              thumbnail: { 
                format: 'jpg',
    						size: '200x150>',
    						datastream: 'thumbnail'
    					}
    				}, processor: :raw_image
          end
        end
      end
    end
  end
end

