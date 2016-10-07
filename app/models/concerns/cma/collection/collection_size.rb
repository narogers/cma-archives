module CMA
  module Collection
    module CollectionSize
      extend ActiveSupport::Concern

      # Go to the bare metal in Solr to use the Stats Component. This might have some limitations
      # so it really needs to be tested but it should be faster than making a query for each member
      # of the collection individually
      def member_bytes
        # Don't even bother if the collection is empty
        return 0 if (0 == members.count)
        query_solr_for_collection_size(self.id)
      end
  
      def subcollection_bytes
        # Despite the fact we have the member_ids array we need to filter
        # out anything that is not a Collection. Thus the need to perform
        # a preliminary request to Solr
        qry = "*:*"
        limits = {
          fl: "id",
          fq: ["{!join from=hasCollectionMember_ssim to=id}id:#{id}",
               "has_model_ssim:Collection"],
          rows: members.count
        }
        collection_ids = ActiveFedora::SolrService.query(qry, limits)

        bytes = 0
        if collection_ids.size > 0
          collection_ids.map! {|coll| coll["id"] }
          collection_ids.each_slice(500) do |ids|
            bytes += query_solr_for_collection_size(ids.join(" "))
          end
        end
        
        # Return the final tally
        bytes
      end

      def bytes
         member_bytes + subcollection_bytes
      end

      private
        def query_solr_for_collection_size(id)
          qry = "*:*"
          limits = {
            fq: ["{!join from=hasCollectionMember_ssim to=id}id:(#{id})",
               "has_model_ssim:GenericFile"],
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

          results = ActiveFedora::SolrService.query(qry, limits)
          total_bytes = results["stats"]["stats_fields"][file_size_field].present? ? results["stats"]["stats_fields"][file_size_field]["sum"] : 0 

          return total_bytes
        end
 
        def file_size_field
          @file_size_field ||= Solrizer.solr_name("file_size", :stored_sortable, type: :long)
        end
    end
  end  
end
