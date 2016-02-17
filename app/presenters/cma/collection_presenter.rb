module CMA
  class CollectionPresenter < Sufia::CollectionPresenter
    include Hydra::Presenter
    include ActionView::Helpers::NumberHelper

    def summary
      "#{model.members.count} Members (#{number_to_human_size(model.bytes)})"
    end
  end
end
