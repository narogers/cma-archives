# Treat breadcrumbs differently than in the stock Sufia interface. Instead we want it to
# look like
# 
# Editorial Photography > Parade the Circle > ABC123.dng
# 
# For search results it can stay the way it is ("Back to Search Results")
module CMA
  module Breadcrumbs
    def build_breadcrumbs
      if request.referer =~ /catalog/
        trail_from_referer
      elsif controller_name =~ /files|collections/
        add_breadcrumb_trail_for_resource params[:id]
      else
        default_trail
      end
    end

    def default_trail
      # NO OP for now      
    end

    def trail_from_referer
      add_breadcrumb I18n.t("sufia.bread_crumb.search_results"), request.referer
      item = ActiveFedora::Base.load_instance_from_solr params[:id]
      case item.class.to_s
        when "GenericFile"
          add_breadcrumb_for_resource params[:id], item.title.first
        when "Collection"
          add_breadcrumb_for_collection params[:id], item.title
      end
    end

    def add_breadcrumb_for_resource id, label
      add_breadcrumb label, sufia.generic_file_path(id)
    end

    def add_breadcrumb_for_collection id, label
      add_breadcrumb label, collections.collection_path(id)
    end

    def add_breadcrumb_for_administrative_collection id, label
      facet = ActiveFedora::SolrQueryBuilder.solr_name(:administrative_collection, :facetable)
      add_breadcrumb label, catalog_index_path("f[#{facet}][]": label)
    end

    def add_breadcrumb_trail_for_resource id
      item = ActiveFedora::Base.load_instance_from_solr(id)
 
      add_breadcrumb_for_administrative_collection item.administrative_collection.id, item.administrative_collection.title
      # Because routes are in different engines we can't just use url_for
      # in this situation
      if "Collection" == item.class.to_s
        add_breadcrumb_for_collection item.id, item.title
      elsif "GenericFile" == item.class.to_s
        coll = ::Collection.load_instance_from_solr item.collection_ids.first
        add_breadcrumb_for_collection coll.id, coll.title
        add_breadcrumb_for_resource item.id, item.title.first
      end
    end
  end
end
