module CMA
  class FixityService < ActiveFedora::FixityService
    attr_accessor :file

    def initialize id
      @file = ::GenericFile.load_instance_from_solr id
      @target = @file.uri + "/content"
    end

    def fixity
      @response = fixity_response_from_fedora if @response.nil?
      urns = fixity_graph.query(predicate: premis_digest_predicate).map(&:object)
      urns.map! { |urn| urn.value.split(":").last }
    end

    private
      def premis_digest_predicate
        ::RDF::Vocab::PREMIS.hasMessageDigest
      end
   
  end
end
