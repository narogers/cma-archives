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
  end
end
