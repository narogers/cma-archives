class GenericFile < ActiveFedora::Base
	include Hydra::Derivatives
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::MimeTypes
    include Sufia::GenericFile::Export
    include Sufia::GenericFile::Characterization
    include Sufia::GenericFile::Permissions
    #include Sufia::GenericFile::Trophies
    #include Sufia::GenericFile::Featured
    include Sufia::GenericFile::Versions
    include Sufia::GenericFile::ProxyDeposit
    include Hydra::Collections::Collectible
    include Sufia::GenericFile::Batches

    include CMA::GenericFile::Characterization
    include CMA::GenericFile::Content
    include CMA::GenericFile::Derivatives
    include CMA::GenericFile::Indexing
    include CMA::GenericFile::MimeTypes
    include CMA::GenericFile::Metadata

    include Rails.application.routes.url_helpers

    before_save :verify_mime_type

    def base_uri
      generic_file_path(self)
    end

    def local_file
      pairs = id.scan(/..?/).first(4)
      File.join(CMA.config["repository"]["root"], *pairs, id)
    end
end
