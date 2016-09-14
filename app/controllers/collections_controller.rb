class CollectionsController < ApplicationController
  include Sufia::CollectionsControllerBehavior
  include CMA::Breadcrumbs

  protected
    def presenter_class
      CMA::CollectionPresenter
    end

    def presenter
      member_ids = @member_docs.map { |m| m.id }
      @presenter ||= presenter_class.new(@collection, member_ids)
    end
end
