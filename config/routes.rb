Rails.application.routes.draw do
  # Needed until ImportUrl no longer relies on BrowseEverything Retriever?
  mount BrowseEverything::Engine => '/browse'
  
  #blacklight_for :catalog
  mount Blacklight::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new

  resource :catalog, only: [:index], controller: 'catalog' do
    concerns :searchable
  end
  resources :solr_documents, only: [:show], controller: 'catalog' do
    concerns :exportable
  end 
  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
 
  devise_for :users
  Hydra::BatchEdit.add_routes(self)
  # This must be the very last route in the file because it has a catch-all route for 404 errors.
    # This behavior seems to show up only in production mode.
    mount Sufia::Engine => '/'
  root to: 'homepage#index'
end
