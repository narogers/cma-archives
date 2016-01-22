module CMA
  module GenericFile
    module Indexing
      extend ActiveSupport::Concern

      module ClassMethods
        def indexer
          CMA::GenericFileIndexingService
        end
      end
    end
  end
end
