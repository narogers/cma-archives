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
        add_breadcrumb_for_resource params[:id]
    end

    def add_breadcrumb_for_resource resource_id
      item = ActiveFedora::Base.load_instance_from_solr(resource_id)

      case item.class.to_s
        when "GenericFile"
          add_breadcrumb item.title.first, sufia.generic_file_path(item.id)
        when "Collection"
          add_breadcrumb item.title, collections.collection_path(item.id)
      end
    end

    def add_breadcrumb_trail_for_resource id
      item = ActiveFedora::Base.load_instance_from_solr(id)
      breadcrumb_ids = [item.id]
  
      while item.collection_ids.present?
        breadcrumb_ids.unshift item.collection_ids.first
        item = ActiveFedora::Base.load_instance_from_solr(item.collection_ids.first)
      end
    
      breadcrumb_ids.each { |b_id| add_breadcrumb_for_resource(b_id) } 
    end
  end
end
