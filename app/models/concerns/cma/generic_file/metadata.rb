# Add additional RDF properties for the Cleveland Museum of
# Art's needs
module CMA
  module GenericFile
    module Metadata
      extend ActiveSupport::Concern
      include Sufia::GenericFile::Metadata

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
        property :category, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#category") do |index|
          index.as :stored_searchable
        end
 
        property :abstract, predicate: ::RDF::DC.abstract do |index|
          index.as :stored_searchable
        end
        property :provenance, predicate: ::RDF::DC.provenance do |index|
          index.as :stored_searchable
        end

        property :credit_line, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#creditline") do |index|
          index.as :stored_searchable
        end
        property :photographer, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#photographer") do |index|
          index.as :stored_searchable
        end
        property :photographer_title, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#photographerTitle") do |index|
          index.as :stored_searchable
        end
        property :accession_number, predicate: ::RDF::URI.new("http://vocab.getty.edu/aat/300312355") do |index|
          index.as :stored_searchable
        end

        property :accession_number, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#accession") do |index|
          index.as :stored_searchable
        end
     end
    end
  end
end
