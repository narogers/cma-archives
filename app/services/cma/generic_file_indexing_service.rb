module CMA
  class GenericFileIndexingService < ActiveFedora::IndexingService
    STORED_INDEXED_INTEGER = Solrizer::Descriptor.new(:integer, :stored, :indexed)

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('label')] = object.label
        solr_doc[Solrizer.solr_name('file_format')] = object.file_format
        solr_doc[Solrizer.solr_name('file_format', :facetable)] = object.file_format
        # Enable if full text indexing is ever required
        #solr_doc['all_text_timv'] = object.full_text.content
        solr_doc[Solrizer.solr_name('file_size', STORED_INDEXED_INTEGER)] = object.content.size.to_i
        solr_doc[Solrizer.solr_name('mime_type', :symbol)] = object.mime_type
        # Index the Fedora-generated SHA1 digest to create a linkage
        # between files on disk (in fcrepo.binary-store-path) and objects
        # in the repository.
        solr_doc[Solrizer.solr_name('digest', :symbol)] = digest_from_content
        # Put the thumbnail and access copies into Solr for faster retrieval if they are
        # present
        solr_doc["thumbnail_uri_ssm"] = object.thumbnail.uri.to_s
        solr_doc["preview_uri_ssm"] = object.access.uri.to_s
        # Sorting fields cannot be multivalued
        solr_doc[Solrizer.solr_name("primary_title", :stored_sortable)] = object.title.first unless object.title.empty?

        object.index_collection_ids(solr_doc) unless Sufia.config.collection_facet.nil?
      end
    end

    private

      def digest_from_content
        return unless object.content.has_content?
        object.content.digest.first.to_s
      end
  end
end
