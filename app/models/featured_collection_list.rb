class FeaturedCollectionList
  include ActiveModel::Model

  # Since we don't manage these through the interface we do not need to imitate
  # the attributes setter
  #
  # However we do need to create a constructor
  def featured_collections
    return @collections if @collections
  
    @collections = FeaturedCollection.all
    add_solr_document_to_collections
    @collections = @collections.reject do |coll|
      # Remove any collections which no longer exist
      coll.destroy if coll.collection_solr_document.blank?
      coll.collection_solr_document.blank?
    end
  end

  private
    def add_solr_document_to_collections
      solr_docs.each do |doc|
        collection_with_id(doc["id"]).collection_solr_document = SolrDocument.new(doc)
      end
    end

    def ids
      @collections.pluck(:collection_id)
    end

    def solr_docs
      ActiveFedora::SolrService.query(ActiveFedora::SolrQueryBuilder.construct_query_for_ids(ids))
    end
   
    def collection_with_id(id)
      @collections.find { |c| c.collection_id == id }
    end
end
