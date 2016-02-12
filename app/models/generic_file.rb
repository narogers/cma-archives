class GenericFile < ActiveFedora::Base
	# TODO : Remove any includes that are not needed once the
	# 			 interface has been cleaned up
	include Hydra::Derivatives
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::MimeTypes
    include Sufia::GenericFile::Export
    include Sufia::GenericFile::Characterization
    include Sufia::GenericFile::Permissions
    include Sufia::GenericFile::Trophies
    include Sufia::GenericFile::Featured
    include Sufia::GenericFile::Metadata
    include Sufia::GenericFile::Versions
    include Sufia::GenericFile::ProxyDeposit
    include Hydra::Collections::Collectible
    include Sufia::GenericFile::Batches
    include Sufia::GenericFile::FullTextIndexing

    include CMA::GenericFile::Content
    include CMA::GenericFile::Derivatives
    include CMA::GenericFile::Indexing
    include CMA::GenericFile::MimeTypes
    include CMA::GenericFile::Metadata

    before_save :verify_mime_type
end
