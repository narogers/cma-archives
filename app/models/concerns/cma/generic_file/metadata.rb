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
        # TODO: Migrate this property to a MARC Relator field (pht)
        property :photographer, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#photographer") do |index|
          index.as :stored_searchable
        end
        property :photographer_title, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#photographerTitle") do |index|
          index.as :stored_searchable
        end
        property :technician, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#technician") do |index|
          index.as :stored_searchable
        end

        #property :accession_number, predicate: ::RDF::URI.new("https://vocab.getty.edu/aat/300312355") do |index|
        property :accession_number, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#accession") do |index|
         index.as :stored_searchable
        end

        property :device, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#capture_device") do |index|
          index.as :stored_searchable
        end

        # TODO: Give this field a better RDF mapping
        property :stored_mime_type, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#mime_type") do |index|
          index.as :stored_searchable
        end

        # Conservation specific metadata fields
        #
        # These terms should be using Getty AAT but due to an issue with
        # numeric identifiers and Jena that will cause instant exceptions deep
        # in the Java stack. For now the workaround is to use a local term
        # instead
        #property :division, predicate: ::RDF::URI.new("https://vocab.getty.edu/aat/300263526") do |index|
        property :division, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#division") do |index|
          index.as :stored_searchable
        end

        property :conservation_type, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#conservation_type") do |index|
          index.as :stored_searchable
        end

        property :conservation_state, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#conservation_state") do |index|
          index.as :stored_searchable
        end

        #property :component, predicate: ::RDF::URI.new("https://vocab.getty.edu/aat/300190691") do |index|
        property :component, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#component") do |index|
          index.as :stored_searchable
        end

        #property :lighting, predicate: ::RDF::URI.new("https://vocab.getty.edu/aat/300191389") do |index|
        property :lighting, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#lighting") do |index|
          index.as :stored_searchable
        end

        property :sample_id, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#sample_id")

        #property :technique, predicate: ::RDF::URI.new("https://vocab.getty.edu/aat/300081683") do |index|
        property :technique, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns/#technique") do |index|
          index.as :stored_searchable
        end
      end
    end
  end
end
