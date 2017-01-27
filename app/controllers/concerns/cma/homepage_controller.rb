# Overrides for CMA specific behavours
module CMA
  module HomepageController
    extend ActiveSupport::Concern

    include Sufia::HomepageControllerBehavior

    def index
      @collection_list = AdministrativeCollection.all.sort { |a, b| a.title.first <=> b.title.first }
    end
  end
end
