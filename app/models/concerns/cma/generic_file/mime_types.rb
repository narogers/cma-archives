module CMA
  module GenericFile
    module MimeTypes
      extend ActiveSupport::Concern

      module ClassMethods
      	def raw_image_mime_types
      		['image/x-adobe-dng']
      	end
      end
    end
  end
end