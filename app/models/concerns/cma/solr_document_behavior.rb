module CMA
  module SolrDocumentBehavior
    def source
      # TODO: Define the prefix to strip in the CatalogController instead of using
      #       import_url
      fetch(Solrizer.solr_name('import_url', :symbol)).first
    end

    def subject
      fetch(Solrizer.solr_name('subject', :stored_searchable))
    end
  end
end
