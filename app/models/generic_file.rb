class GenericFile < ActiveFedora::Base
    include Sufia::GenericFile
    include CMA::Metadata

    # Override the default MIME types in GenericFile::MimeTypes to
    # include DNGs
    def self.image_mime_types
   	  return ['image/tiff', 'image/jpg', 'image/x-adobe-dng']
    end
end