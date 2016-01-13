module CMA
  module Collection
    module CollectionSize
      extend ActiveSupport::Concern

      # Go to the bare metal in Solr to use the Stats Component. This might have some limitations
      # so it really needs to be tested but it should be faster than making a query for each member
      # of the collection individually
      def bytes
        qry = "*:*"
        limits = {
          fq: "{!join from=hasCollectionMember_ssim to=id}id:#{id}",
          # It doesn't really matter what we pull here since it is ignored
          fl: "id",
          # And we don't even need all the results
          rows: 1,
          # But these do matter since they are the magic parts of the URL
          stats: 'true',
          "stats.field" => file_size_field,
          # And make it raw to get the right part of the response
          raw: true
        }

        results = ActiveFedora::SolrService.query(qry, limits);
        # TODO: Implement some sort of error handling
        return results["stats"]["stats_fields"][file_size_field]["sum"]
      end
    
      private
    
        def file_size_field
          "file_size_isi"
        end
    end
  end  
end
