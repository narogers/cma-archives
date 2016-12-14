# Overrides for Blacklight, Sufia, and general HYdra controller behaviours
module CMA
  module Controller
    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end

    def notifications_number
      # NO OP
    end
  end  
end
