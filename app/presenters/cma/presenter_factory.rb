module CMA
  class PresenterFactory
    class << self
      # @param [Array] ids List of IDs to load
      # @param [Class] klass Presenter class
      # @param [Array] args Additional parameters to pass
      # @return [Array] presenters Ordered by the first argument
      def build_presenters(ids, klass, *args)
        new(ids, klass, *args).build
      end
    end

    attr_reader :ids, :klass, :args

    def initialize(ids, klass, *args)
      @ids = ids
      @klass = klass
      @args = args
    end

    def build
      return [] if ids.blank?

      solr_docs = load_documents
      ids.map do |id|
        solr_doc = solr_docs.find { |doc| doc.id == id }
        klass.new(solr_doc, *args) if solr_doc
      end
    end

    private
      # @return [Array<SolrDocument>] List of unordered Solr documents
      def load_documents
        query("{!terms f=id}#{ids.join(' ')}", rows: 500)
          .map { |result| SolrDocument.new(result) } 
      end

      def query(query, *args) 
        args[:q] = query
        args[:qt] = 'standard'
        conn = ActiveFedora::SolrService.instance.conn
        result = conn.post('select', data: args)
        result.fetch('response').fetch('docs')
      end
  end
end
