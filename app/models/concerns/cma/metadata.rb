# Add additional RDF properties for the Cleveland Museum of
# Art's needs
module CMA
  module Metadata
  extend ActiveSupport::Concern

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

    property :credit_line, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#creditline") do |index|
      index.as :stored_searchable
    end
    property :photographer, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#photographer") do |index|
      index.as :stored_searchable
    end
    property :photographer_title, predicate: ::RDF::URI.new("http://library.clevelandart.org/ns#photographerTitle") do |index|
      index.as :stored_searchable
    end
  end
end
end