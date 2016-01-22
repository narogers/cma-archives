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
      # Noop
    end

    def trail_from_referer
      case request.referer
      when /catalog/
        add_breadcrumb I18n.t("sufia.bread_crumb.search_results"), request.referer
      else
        add_breadcrumb_for_parent_collection collection.collections.first unless collection.collections.empty?
      end  
      add_breadcrumb_for_resource
    end
 
    # Definitely need to revisit for GenericFile level views 
    def add_breadcrumb_for_resource
       add_breadcrumb collection.title, collections.collection_path(collection.id)
    end

    def add_breadcrumb_for_parent_collection parent=nil
      return if parent.nil?
      # We have more levels to traverse
      unless parent.collections.empty?
        add_breadcrumb_for_parent_collection parent.collections.first
      end
      # Then stick on this level
      add_breadcrumb parent.title, collections.collection_path(parent.id)
    end
  end
end
