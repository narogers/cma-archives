class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  include CMA::Breadcrumbs
  include CMA::Collection::ResourceBehavior
end