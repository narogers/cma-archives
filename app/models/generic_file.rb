class GenericFile < ActiveFedora::Base
    include Sufia::GenericFile
    include CMA::Metadata

    # Override the default MIME types in GenericFile::MimeTypes to
    # include DNGs
    def self.raw_image_mime_types
   	  return ['image/x-adobe-dng']
    end

    # Use a different method so as to not step on the toes of the
    # existing Sufia code base for now
    self.makes_derivatives :generate_cma_derivatives

    # Add to this in the future when Time Based Media and Archival PDFs
    # become part of the repository. For now focus only on image based
    # formats
    def self.generate_cma_derivatives
    	case mime_type
    	when *image_mime_types
    		obj.transform_file :content, { thumbnail: 
    			{ format: 'jpg',
    				size: '200x150>',
    				datastream: 'thumbnail'
    			}
    		}
    	when *raw_image_mime_types
    		obj.transform_file :content, { thumbnail:
    			{ format: 'jpg',
    				size: '200x150>',
    				datastream: 'thumbnail'
    			}, processor: :raw_image
    	}
    	end
    end
end