class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  include CMA::Breadcrumbs
end
