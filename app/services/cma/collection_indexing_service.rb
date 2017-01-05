module CMA
  class CollectionIndexingService < ActiveFedora::IndexingService
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name("date_created", :stored_sortable)] = object.date_created.first unless object.date_created.blank?
        solr_doc[Solrizer.solr_name("primary_title", :stored_sortable)] = object.title unless object.title.blank?
        solr_doc[Solrizer.solr_name("umbrella_collection", :facetable)] = object.administrative_collection.title unless object.administrative_collection.nil?
        # TODO: Index resource type here?
      end
    end
  end
end
