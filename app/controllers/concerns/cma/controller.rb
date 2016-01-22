# Overrides for Blacklight, Sufia, and general HYdra controller behaviours
module CMA
  module Controller
    # Crib this from Devise examples in the Platformatec wiki
    def after_sign_in_path_for(_resource)
      sign_in_url = new_user_session_url
      if request.referer == sign_in_url
        super
      else
        request.referer || root_path
      end
    end
  end  
end
