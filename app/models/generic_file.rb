class GenericFile < ActiveFedora::Base
    include Sufia::GenericFile
    include CMA::GenericFile::Derivatives
    include CMA::GenericFile::MimeTypes
    include CMA::GenericFile::Metadata

    before_save :verify_mime_type
end
