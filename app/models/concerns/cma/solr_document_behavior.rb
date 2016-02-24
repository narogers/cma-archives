module CMA
  module SolrDocumentBehavior
    def source
      source_field = Solrizer.solr_name('source', :stored_searchable)
      if has? source_field
        fetch(source_field).first
      else
        nil
      end
    end

    def subject
      subject_field = Solrizer.solr_name('subject', :stored_searchable)
      if has? subject_field
        fetch(subject_field)
      else
        []
      end
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
        fetch("file_size_isi")
      end  
    end

    # Not to be confused with the date that the Collection object was created
    # this returns the date according to the metadata during batch ingest
    def date_created
      Array(self[Solrizer.solr_name("date_created")]).first
    end
  end
end
