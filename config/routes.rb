Rails.application.routes.draw do
  # Needed until ImportUrl no longer relies on BrowseEverything Retriever?
  mount BrowseEverything::Engine => '/browse'
  
  blacklight_for :catalog
  devise_for :users
  Hydra::BatchEdit.add_routes(self)
  # This must be the very last route in the file because it has a catch-all route for 404 errors.
    # This behavior seems to show up only in production mode.
    mount Sufia::Engine => '/'
  root to: 'homepage#index'
end
