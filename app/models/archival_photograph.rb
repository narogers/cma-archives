class ArchivalPhotograph < GenericFile
    # Override the default MIME types in GenericFile::MimeTypes to
    # include DNGs
   	def self.image_mime_types
   		super << 'image/x-adobe-dng'
    end
end