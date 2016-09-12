class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  include CMA::Breadcrumbs
  #include CMA::Collection::ResourceBehavior

  protected
    def presenter_class
      CMA::CollectionPresenter
    end
end
