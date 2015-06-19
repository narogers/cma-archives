module CMA
  module GenericFile
    module MimeTypes
      extend ActiveSupport::Concern

      module ClassMethods
      	def image_mime_types
      		['image/tiff', 'image/jpeg', 'image/x-adobe-dng']
      	end
      end
    end
  end
end