module CMA
  class GenericFileIndexingService < ActiveFedora::IndexingService
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('label')] = object.label
        solr_doc[Solrizer.solr_name('file_format')] = object.file_format
        solr_doc[Solrizer.solr_name('file_format', :facetable)] = object.file_format
        # Enable if full text indexing is ever required
        solr_doc[Solrizer.solr_name('file_size', :stored_sortable, type: :long)] = object.content.size.to_i
        solr_doc[Solrizer.solr_name('mime_type', :symbol)] = object.mime_type
        # Index the Fedora-generated SHA1 digest to create a linkage
        # between files on disk (in fcrepo.binary-store-path) and objects
        # in the repository.
        solr_doc[Solrizer.solr_name('digest', :symbol)] = digest_from_content
        solr_doc[Solrizer.solr_name('photographer')] = object.photographer
        solr_doc[Solrizer.solr_name('accession_number', :stored_searchable)] = accession_number_ranges

        # For faceting and discovery
        solr_doc[Solrizer.solr_name('contributor_facet', :facetable)] = object.contributor + object.photographer 
        solr_doc[Solrizer.solr_name('umbrella_collection', :facetable)] = umbrella_collection
          
        # Put the thumbnail and access copies into Solr for faster retrieval if they are
        # present
        solr_doc["thumbnail_uri_ssm"] = object.thumbnail.uri.to_s
        solr_doc["preview_uri_ssm"] = object.access.uri.to_s
        # Sorting fields cannot be multivalued
        solr_doc[Solrizer.solr_name("primary_title", :stored_sortable)] = object.title.first unless object.title.empty?
        solr_doc[Solrizer.solr_name("date_created", :stored_sortable)] = object.date_created.first unless object.date_created.blank?

        object.index_collection_ids(solr_doc) unless Sufia.config.collection_facet.nil?
      end
    end

    private
      def accession_number_ranges
        return unless object.accession_number.present?

        values = []
        object.accession_number.each do |an|
          parts = an.split(".")
          value = parts.shift
    
          parts.each do |fragment|
            value += ".#{fragment}"
            values << value
          end
        end
  
        values
      end

      def digest_from_content
        return unless object.content.has_content?
        object.content.digest.first.to_s
      end

      def umbrella_collection
        return nil if object.collections.first.nil?

        maximum_depth = 2
        pointer = object
        while (maximum_depth > 0 and not pointer.collections.first.nil?)
          pointer = pointer.collections.first
          maximum_depth = maximum_depth - 1
        end 

        return pointer.title
      end
  end
end
