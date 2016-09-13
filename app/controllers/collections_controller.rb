class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  include CMA::Breadcrumbs

  protected
    def presenter_class
      CMA::CollectionPresenter
    end
end
