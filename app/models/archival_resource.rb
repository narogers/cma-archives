class ArchivalResource < GenericFile
    # Override the default MIME types in GenericFile::MimeTypes to
    # include DNGs
   	def self.image_mime_types
   		super << 'image/x-adobe-dng'
    end

    # In this case we only care about images so override 
    # sufia-models/app/models/concerns/sufia/generic_file/derivatives.rb
    # to remove the other cases
    makes_derivatives do |obj|
    	case obj.mime_type
    	when *image_mime_types
    		obj.transform_file :content,
    			{ thumbnail: { format: 'png', size: '200x150',
    				datastream: 'thumbnail'}}
    	end
    end
end