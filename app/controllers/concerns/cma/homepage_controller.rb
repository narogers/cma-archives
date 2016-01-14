# Overrides for CMA specific behavours
module CMA
  module HomepageController
    extend ActiveSupport::Concern

    include Sufia::HomepageController

    def index
      @featured_collection_list = FeaturedCollectionList.new
    end
  end
end
