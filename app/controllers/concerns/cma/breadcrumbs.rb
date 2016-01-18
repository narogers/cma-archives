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
        add_breadcrumb_for_controller
        add_breadcrumb_for_action
      end  
    end
  
    def add_breadcrumb_for_controller
      add_breadcrumb Proc.new { |c|  }, 
        Proc.new { |c| sufia.generic_file_path(params["id"] )} 
    end

    def add_breadcrumb_for_action
      add_breadcrumb I18n.t("sufia.generic_file.browse_view"), 
        sufia.generic_file_path(params["id"]), only: %w(edit stats),
        if: ("generic_files" == controller_name)
    end
  end
end
