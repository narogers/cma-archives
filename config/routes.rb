Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end
  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # Needed until ImportUrl no longer relies on BrowseEverything Retriever?
  mount BrowseEverything::Engine => '/browse'
  
  mount CurationConcerns::Engine, at: '/'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  # This must be the very last route in the file because it has a catch-all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
  root to: 'homepage#index'
end
