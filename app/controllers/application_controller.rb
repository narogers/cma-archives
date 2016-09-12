class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  #helper Openseadragon::OpenseadragonHelper
  layout 'sufia-one-column'

  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller  
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller
  include CMA::Controller

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
end
