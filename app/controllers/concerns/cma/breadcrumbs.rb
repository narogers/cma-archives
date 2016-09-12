# Treat breadcrumbs differently than in the stock Sufia interface. Instead we want it to
# look like
# 
# Editorial Photography > Parade the Circle > ABC123.dng
# 
# For search results it can stay the way it is ("Back to Search Results")
module CMA
  module Breadcrumbs
    def build_breadcrumbs
      if request.referer
        trail_from_referer
      else
        default_trail
      end
    end

    def default_trail
      # NO OP for now      
    end

    def trail_from_referer
      if (request.referer =~ /catalog/)
        add_breadcrumb I18n.t("sufia.bread_crumb.search_results"), request.referer
      end
      add_breadcrumb_for_resource params[:id]
    end

    def add_breadcrumb_for_resource resource_id
      item = ActiveFedora::Base.load_instance_from_solr(resource_id)

      unless item.collection_ids.blank?
        add_breadcrumb_for_resource item.collection_ids.first
      end

      case item.class
        when GenericFile
          add_breadcrumb I18n.t(item.title.first), sufia.generic_file_path(item.id)
        when Collection
          add_breadcrumb I18n.t(item.title), collections.collection_path(item.id)
      end
    end
  end
end
