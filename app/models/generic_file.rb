class GenericFile < ActiveFedora::Base
	extend ActiveSupport::Concern
    include Sufia::GenericFile

    # Add additional RDF properties for the Cleveland Museum of
    # Art's needs
    included do
    	property :spatial, predicate: ::RDF::DC.spatial do |index|
    		index.as :stored_searchable, :facetable
    	end
    	property :coverage, predicate: ::RDF::DC.coverage do |index|
    		index.as :stored_searchable, :facetable
    	end
    	property :temporal, predicate: ::RDF::DC.temporal do |index|
    		index.as :stored_searchable
    	end

    	property :abstract, predicate: ::RDF::DC.abstract do |index|
    		index.as :stored_searchable
    	end
    	property :provenance, predicate: ::RDF::DC.provenance do |index|
    		index.as :stored_searchable
    	end
    end

    # Override the default MIME types in GenericFile::MimeTypes to
    # include DNGs
    def self.image_mime_types
   	  return ['image/tiff', 'image/jpg', 'image/x-adobe-dng']
    end
end