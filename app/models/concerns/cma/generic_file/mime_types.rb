module CMA
  module GenericFile
    module MimeTypes
      extend ActiveSupport::Concern

      module ClassMethods
      	def image_mime_types
      	  ['image/tiff', 'image/jpeg', 'image/x-adobe-dng',
           'image/vnd.adobe.photoshop']
      	end

        def layered_image_mime_types
          ['image/tiff', 'image/x-adobe-dng', 'image/vnd.adobe.photoshop']
        end
      end
    end
  end
end
