module CMA
  module SolrDocumentBehavior
    def source
      source_field = Solrizer.solr_name('source', :stored_searchable)
      has?(source_field) ? fetch(source_field).first : nil
    end

    def subject
      subject_field = Solrizer.solr_name('subject', :stored_searchable)
      has?(subject_field) ? fetch(subject_field) : []
    end

    def members
      case hydra_model
      when "Collection"
        has?("hasCollectionMember_ssim") ? fetch("hasCollectionMember_ssim") : []
      else
        nil
      end
    end

    # This assumes that the bytes method for collections is already included
    # in your module. Be sure to also mixin CMA::Collection::CollectionSize
    # if relying on this module
    def bytes
      case hydra_model
      when "Collection"
        super
      else
        fetch(Solrizer.solr_name("file_size", :stored_sortable, type: :long))
      end  
    end

    def date_created
      Array(self[Solrizer.solr_name("date_created")]).first
    end
  end
end
