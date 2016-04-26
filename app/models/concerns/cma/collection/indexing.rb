module CMA
  module Collection
    module Indexing
      extend ActiveSupport::Concern

      module ClassMethods
        def indexer
          CMA::CollectionIndexingService
        end
      end
    end
  end
end
