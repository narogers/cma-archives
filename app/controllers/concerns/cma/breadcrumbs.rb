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
      case request.referer
      when /catalog/
        add_breadcrumb I18n.t("sufia.bread_crumb.search_results"), request.referer
      else
        add_breadcrumb_for_parent resource.collections.first 
      end  
      add_breadcrumb_for_resource resource
    end

    def add_breadcrumb_for_resource item
      case item.title
      when Array
        add_breadcrumb item.title.first, sufia.generic_file_path(item.id)
      when String
        add_breadcrumb item.title, collections.collection_path(item.id)
      end
    end

    def add_breadcrumb_for_parent parent=nil
      return if parent.nil?
      # We have more levels to traverse
      unless parent.collections.empty?
        add_breadcrumb_for_parent parent.collections.first
      end
      # Then stick on this level
      add_breadcrumb_for_resource parent
    end
  end
end
